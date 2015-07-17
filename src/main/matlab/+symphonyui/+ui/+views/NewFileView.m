classdef NewFileView < symphonyui.ui.View

    events
        BrowseLocation
        Open
        Cancel
    end

    properties (Access = private)
        nameField
        locationField
        browseLocationButton
        openButton
        cancelButton
    end

    methods

        function createUi(obj)
            import symphonyui.ui.util.*;

            set(obj.figureHandle, ...
                'Name', 'New File', ...
            	'Position', screenCenter(500, 111));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            parametersLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', parametersLayout, ...
                'String', 'Name:');
            Label( ...
                'Parent', parametersLayout, ...
                'String', 'Location:');
            obj.nameField = uicontrol( ...
                'Parent', parametersLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.locationField = uicontrol( ...
                'Parent', parametersLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            uix.Empty('Parent', parametersLayout);
            obj.browseLocationButton = uicontrol( ...
                'Parent', parametersLayout, ...
                'Style', 'pushbutton', ...
                'String', '...', ...
                'Callback', @(h,d)notify(obj, 'BrowseLocation'));
            set(parametersLayout, ...
                'Widths', [60 -1 25], ...
                'Heights', [25 25]);

            % Open/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uix.Empty('Parent', controlsLayout);
            obj.openButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Open', ...
                'Callback', @(h,d)notify(obj, 'Open'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [-1 75 75]);

            set(mainLayout, 'Heights', [-1 25]);

            % Set open button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.openButton);
            end
        end

        function n = getName(obj)
            n = get(obj.nameField, 'String');
        end

        function setName(obj, n)
            set(obj.nameField, 'String', n);
        end
        
        function requestNameFocus(obj)
            obj.update();
            uicontrol(obj.nameField);
        end

        function l = getLocation(obj)
            l = get(obj.locationField, 'String');
        end

        function setLocation(obj, l)
            set(obj.locationField, 'String', l);
        end

    end

end
