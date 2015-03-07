classdef NewExperimentPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        mainService
    end
    
    methods
        
        function obj = NewExperimentPresenter(mainService, app, view)
            if nargin < 2
                view = symphonyui.ui.views.NewExperimentView([]);
            end
            
            obj = obj@symphonyui.ui.Presenter(app, view);            
            obj.addListener(view, 'BrowseLocation', @obj.onViewSelectedBrowseLocation);
            obj.addListener(view, 'Open', @obj.onViewSelectedOpen);
            obj.addListener(view, 'Cancel', @obj.onViewSelectedClose);
            
            obj.mainService = mainService;
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)
            onViewShown@symphonyui.ui.Presenter(obj);
            
            config = obj.app.config;
            name = config.get(symphonyui.app.Settings.EXPERIMENT_DEFAULT_NAME);
            location = config.get(symphonyui.app.Settings.EXPERIMENT_DEFAULT_LOCATION);
            
            obj.view.setWindowKeyPressFcn(@obj.onViewWindowKeyPress);
            obj.view.setName(name());
            obj.view.setLocation(location());
        end
        
    end
    
    methods (Access = private)
        
        function onViewWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onViewSelectedOpen();
            elseif strcmp(data.Key, 'escape')
                obj.onViewSelectedCancel();
            end
        end
        
        function onViewSelectedBrowseLocation(obj, ~, ~)
            location = uigetdir(pwd, 'Experiment Location');
            if location ~= 0
                obj.view.setLocation(location);
            end
        end
        
        function onViewSelectedOpen(obj, ~, ~)
            obj.view.update();
            
            name = obj.view.getName();            
            location = obj.view.getLocation();
            path = fullfile(location, name);
            
            try
                obj.mainService.openExperiment(path);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
            
            obj.view.close();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.view.close();
        end
        
    end
    
end
