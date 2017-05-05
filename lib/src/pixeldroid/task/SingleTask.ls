package pixeldroid.task
{
    import system.Debug;

    import pixeldroid.task.Task;
    import pixeldroid.task.TaskStart;
    import pixeldroid.task.TaskProgress;
    import pixeldroid.task.TaskFault;
    import pixeldroid.task.TaskComplete;
    import pixeldroid.task.TaskState;


    public class SingleTask implements Task
    {
        private var _currentState:TaskState = TaskState.UNSTARTED;
        private var _enabled:Boolean = true;
        private var _label:String;

        private var _onTaskStart:TaskStart;
        private var _onTaskProgress:TaskProgress;
        private var _onTaskFault:TaskFault;
        private var _onTaskComplete:TaskComplete;

        public function get currentState():TaskState { return _currentState; }

        public function get enabled():Boolean { return _enabled; }
        public function set enabled(value:Boolean):void { _enabled = value; }

        public function get label():String
        {
            if (!_label)
                return this.getFullTypeName();

            return _label;
        }

        public function set label(value:String):void
        {
            _label = value;
        }

        public function addCallback(state:TaskState, callback:Function):void
        {
            switch (state)
            {
                case TaskState.RUNNING:
                    _onTaskStart += callback;
                    break;

                case TaskState.REPORTING:
                    _onTaskProgress += callback;
                    break;

                case TaskState.COMPLETED:
                    _onTaskComplete += callback;
                    break;

                case TaskState.FAULT:
                    _onTaskFault += callback;
                    break;
            }
        }

        public function removeCallback(state:TaskState, callback:Function):void
        {
            switch (state)
            {
                case TaskState.RUNNING:
                    _onTaskStart -= callback;
                    break;

                case TaskState.REPORTING:
                    _onTaskProgress -= callback;
                    break;

                case TaskState.COMPLETED:
                    _onTaskComplete -= callback;
                    break;

                case TaskState.FAULT:
                    _onTaskFault -= callback;
                    break;
            }
        }

        public function start():void
        {
            if (!_enabled)
                return;

            if (_currentState == TaskState.RUNNING)
                return;

            setCurrentState(TaskState.RUNNING);
            _onTaskStart(this);
            performTask();
        }


        protected function performTask():void
        {
            fault('performTask method must be implemented by subclass');
        }

        protected function complete():void
        {
            if (_currentState != TaskState.RUNNING)
                return;

            setCurrentState(TaskState.COMPLETED);
            _onTaskComplete(this);
        }

        protected function fault(message:String = null):void
        {
            if (_currentState != TaskState.RUNNING)
                return;

            setCurrentState(TaskState.FAULT);
            _onTaskFault(this, message);
        }

        protected function progress(percent:Number):void
        {
            if (_currentState != TaskState.RUNNING)
                return;

            _onTaskProgress(this, percent);
        }


        private function setCurrentState(value:TaskState):void
        {
            _currentState = value;
        }
    }
}