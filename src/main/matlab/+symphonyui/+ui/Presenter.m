classdef Presenter < handle
    
    properties
        hideOnViewSelectedClose
    end
    
    properties (SetAccess = private)
        isStopped
    end
    
    properties (Access = protected)
        log
        app
        view
    end
    
    properties (Access = private)
        eventManager
    end
    
    methods
        
        function obj = Presenter(app, view)
            obj.hideOnViewSelectedClose = false;
            obj.isStopped = false;
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.app = app;
            obj.view = view;
            obj.eventManager = symphonyui.ui.util.EventManager();
        end
        
        function delete(obj)
            obj.stop();
        end
        
        function go(obj)
            obj.onGoing();
            obj.bind();
            obj.view.show();
            obj.onGo();
        end
        
        function stop(obj)
            obj.onStopping();
            obj.unbind();
            obj.view.close();
            obj.isStopped = true;
            obj.onStop();
        end
        
        function show(obj)
            obj.view.show();
        end
        
        function hide(obj)
            obj.view.hide();
        end
        
        function goWaitStop(obj)
            obj.go();
            obj.view.wait();
            obj.stop();
        end
        
    end
    
    methods (Access = protected)
        
        function onGoing(obj) %#ok<MANU>
            % Setup view before being shown for the first time.
        end
        
        function onGo(obj) %#ok<MANU>
            % Set focus on view component after being shown for the first time.       
        end
        
        function onStopping(obj) %#ok<MANU>
            % Teardown view before being closed forever.
        end
        
        function onStop(obj) %#ok<MANU>
            
        end
        
        function onBind(obj) %#ok<MANU>
            % Add view/model listeners.
        end
        
        function onUnbind(obj) %#ok<MANU>
            
        end
        
        function l = addListener(obj, varargin)
            l = obj.eventManager.addListener(varargin{:});
        end
        
        function removeAllListeners(obj)
            obj.eventManager.removeAllListeners();
        end
        
        function onViewSelectedClose(obj, ~, ~)
            if obj.hideOnViewSelectedClose
                obj.hide();
            else
                obj.stop();
            end
        end
        
    end
    
    methods (Access = private)
        
        function bind(obj)
            v = obj.view;
            obj.addListener(v, 'Close', @obj.onViewSelectedClose);
            obj.onBind();
        end
        
        function unbind(obj)
            obj.removeAllListeners();
            obj.onUnbind();
        end
        
    end
    
end
