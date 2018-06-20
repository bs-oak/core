import * as scheduler from "./scheduler";

var MSG_SELF = "MSG_SELF";
var MSG_FX = "MSG_FX";
var BAG_LEAF = "BAG_LEAF";
var BAG_NODE = "BAG_NODE";
var BAG_MAP = "BAG_MAP";
var LIST_NIL = 0;

// INITIALIZE A PROGRAM

function initialize(flags, init, update, subscriptions, stepperBuilder) {
    var result = init(flags);
    var model = result[0];
    var stepper = stepperBuilder(sendToApp, model);
    var managers = {};
    startManagers(managers, sendToApp);

    function sendToApp(msg) {
        result = update(msg, model);
        stepper(model = result[0]);
        dispatchEffects(managers, result[1], subscriptions(model));
    }
    dispatchEffects(managers, result[1], subscriptions(model));
}

// EFFECT MANAGERS

var effectManagers = {};

function newEffectManagerCtx() {
    function b(a) { return a ? (a ^ Math.random() * 16 >> a / 4).toString(16) : ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, b) } // UUID V4
    return b();
}

function registerEffectManager(ctx, init, onEffects, onSelfMsg, cmdMap, subMap) {
    effectManagers[ctx] = {
        init: init,
        onEffects: onEffects,
        onSelfMsg: onSelfMsg,
        cmdMap: cmdMap,
        subMap: subMap
    }
}

function registerCommandManager(ctx, init, onEffects, onSelfMsg, cmdMap) {
    registerEffectManager(ctx, init, onEffects, onSelfMsg, cmdMap, undefined);
}

function registerSubscriptionManager(ctx, init, onEffects, onSelfMsg, subMap) {
    registerEffectManager(ctx, init, onEffects, onSelfMsg, undefined, subMap);
}

function startManagers(managers, sendToApp) {
    for (var key in effectManagers) {
        var manager = effectManagers[key];
        managers[key] = startManager(manager, sendToApp);
    }
}

function startManager(manager, sendToApp) {
    var router = {
        sendToApp: sendToApp,
        selfProcess: undefined
    };

    var onEffects = manager.onEffects;
    var onSelfMsg = manager.onSelfMsg;
    var cmdMap = manager.cmdMap;
    var subMap = manager.subMap;

    function loop(state) {
        return scheduler.andThen(loop, scheduler.receive(function (msg) {
            var value = msg.a;

            if (msg.$ === MSG_SELF) {
                return onSelfMsg(router, value, state);
            }

            return cmdMap && subMap
                ? onEffects(router, value.cmds, value.subs, state)
                : onEffects(router, cmdMap ? value.cmds : value.subs, state);
        }))
    }

    return router.selfProcess = scheduler.rawSpawn(scheduler.andThen(loop, manager.init));
}

function dispatchEffects(managers, cmdBag, subBag) {
    var effectsDict = {};
    gatherEffects(true, cmdBag, effectsDict, null);
    gatherEffects(false, subBag, effectsDict, null);

    for (var home in managers) {
        scheduler.rawSend(managers[home], {
            $: MSG_FX,
            a: effectsDict[home] || { cmds: LIST_NIL, subs: LIST_NIL }
        })
    }
}

function gatherEffects(isCmd, bag, effectsDict, taggers) {
    switch (bag.$) {
        case BAG_LEAF:
            var home = bag.home;
            var effect = toEffect(isCmd, home, taggers, bag.value);
            effectsDict[home] = insert(isCmd, effect, effectsDict[home]);
            return;

        case BAG_NODE:
            for (var list = bag.bags; list.b; list = list.b) // WHILE_CONS
            {
                gatherEffects(isCmd, list.a, effectsDict, taggers);
            }
            return;

        case BAG_MAP:
            gatherEffects(isCmd, bag.bag, effectsDict, {
                tagger: bag.func,
                rest: taggers
            });
            return;
    }
}

function toEffect(isCmd, home, taggers, value) {
    function applyTaggers(x) {
        for (var temp = taggers; temp; temp = temp.rest) {
            x = temp.tagger(x);
        }
        return x;
    }

    var map = isCmd
        ? effectManagers[home].cmdMap
        : effectManagers[home].subMap;

    return map(applyTaggers, value);
}

function insert(isCmd, newEffect, effects) {
    effects = effects || { cmds: LIST_NIL, subs: LIST_NIL };

    isCmd
        ? (effects.cmds = [newEffect, effects.cmds]) // LIST CONS
        : (effects.subs = [newEffect, effects.cmds]);

    return effects;
}

// BAGS

function leaf(home, value) {
    return {
        $: BAG_LEAF,
        home: home,
        value: value
    };
}

function batch(list) {
    return {
        $: BAG_NODE,
        bags: list
    };
}

function none() {
    return {
        $: BAG_NODE,
        bags: LIST_NIL
    };
}

function map(tagger, bag) {
    return {
        $: BAG_MAP,
        func: tagger,
        bag: bag
    }
}

// ROUTING


function sendToApp(router, msg) {
    return scheduler.binding(function (callback) {
        router.sendToApp(msg);
        callback(scheduler.succeed(0));
    });
}

function sendToSelf(router, msg) {
    return scheduler.send(router.selfProcess, {
        $: MSG_SELF,
        a: msg,
    });
}

// EXPORT

export {
    initialize,
    leaf,
    batch,
    none,
    map,
    sendToApp,
    sendToSelf,
    newEffectManagerCtx,
    registerEffectManager,
    registerCommandManager,
    registerSubscriptionManager
};