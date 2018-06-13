var SUCCEED = 0;
var FAIL = 1;
var BINDING = 2;
var AND_THEN = 3;
var ON_ERROR = 4;
var RECEIVE = 5;
var PROCESS = 6;
var NULL = null;

function succeed(value) {
    return {
        $: SUCCEED,
        value: value
    };
}

function fail(error) {
    return {
        $: FAIL,
        value: error
    };
}

function binding(callback) {
    return {
        $: BINDING,
        callback: callback,
        kill: null
    };
}

function andThen(callback, task) {
    return {
        $: AND_THEN,
        callback: callback,
        task: task
    };
};

function onError(callback, task) {
    return {
        $: ON_ERROR,
        callback: callback,
        task: task
    };
};

function receive(callback) {
    return {
        $: RECEIVE,
        callback: callback
    };
}


// PROCESSES

var guid = 0;

function rawSpawn(task) {
    var proc = {
        $: PROCESS,
        id: guid++,
        root: task,
        stack: null,
        mailbox: []
    };

    enqueue(proc);

    return proc;
}

function spawn(task) {
    return binding(function (callback) {
        callback(succeed(rawSpawn(task)));
    });
}

function rawSend(proc, msg) {
    proc.mailbox.push(msg);
    enqueue(proc);
}

function send(proc, msg) {
    return binding(function (callback) {
        rawSend(proc, msg);
        callback(succeed(NULL));
    });
};

function kill(proc) {
    return binding(function (callback) {
        var task = proc.root;
        if (task.$ === BINDING && task.kill) {
            task.kill();
        }

        proc.root = null;

        callback(succeed(NULL));
    });
}

/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/

var working = false;
var queue = [];

function enqueue(proc) {
    queue.push(proc);
    if (working) {
        return;
    }
    working = true;
    while (proc = queue.shift()) {
        step(proc);
    }
    working = false;
}

function step(proc) {
    while (proc.root) {
        var rootTag = proc.root.$;
        if (rootTag === SUCCEED || rootTag === FAIL) {
            while (proc.stack && proc.stack.$ !== rootTag) {
                proc.stack = proc.stack.rest;
            }
            if (!proc.stack) {
                return;
            }
            proc.root = proc.stack.callback(proc.root.value);
            proc.stack = proc.stack.rest;
        }
        else if (rootTag === BINDING) {
            proc.root.kill = proc.root.callback(function (newRoot) {
                proc.root = newRoot;
                enqueue(proc);
            });
            return;
        }
        else if (rootTag === RECEIVE) {
            if (proc.mailbox.length === 0) {
                return;
            }
            proc.root = proc.root.callback(proc.mailbox.shift());
        }
        else // if (rootTag === AND_THEN || rootTag === ON_ERROR)
        {
            proc.stack = {
                $: rootTag === AND_THEN ? SUCCEED : FAIL,
                callback: proc.root.callback,
                rest: proc.stack
            };
            proc.root = proc.root.task;
        }
    }
}

export {
    succeed,
    fail,
    binding,
    andThen,
    onError,
    receive,
    rawSpawn,
    spawn,
    rawSend,
    send,
    kill
};