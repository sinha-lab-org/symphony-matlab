classdef ProtocolPresetsView < appbox.View

    events
        SelectedProtocolPreset
        ViewOnlyProtocolPreset
        RecordProtocolPreset
        StopProtocolPreset
        AddProtocolPreset
        RemoveProtocolPreset
        ApplyProtocolPreset
        UpdateProtocolPreset
        UpdateProtocolPresetsChain
        ViewOnlyProtocolPresetsChain
        RecordProtocolPresetsChain
        PauseProtocolPresetsChain
        StopProtocolPresetsChain
    end

    properties (Access = private)
        presetsTable
        presetsChainTableLabel
        presetsChainTable
        viewOnlyButton
        recordButton
        stopButton
        addToChainButton
        addButton
        removeButton
        updateMenu
        moveUpChainButton
        moveDownChainButton
        removeFromChainButton
        pauseChainButton
        stopChainButton
        viewOnlyChainButton
        recordChainButton
    end

    methods

        function createUi(obj)
            import appbox.*;
            import symphonyui.app.App;

            set(obj.figureHandle, ...
                'Name', 'Protocol Presets', ...
                'Position', screenCenter(360, 200));

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Spacing', 1);

            presetsLayout = uix.HBoxFlex( ...
                'Parent', mainLayout);

            presetsTableLayout = uix.VBox( ...
                'Parent', presetsLayout);

            filterLayout = uix.HBox( ...
                'Parent', presetsTableLayout);

            obj.presetsTable = uiextras.jTable.Table( ...
                'Parent', presetsTableLayout, ...
                'ColumnName', {'Preset', 'View Only', 'Record', 'AddToChain'}, ...
                'ColumnFormat', {'', 'button', 'button', 'button'}, ...
                'ColumnFormatData', ...
                    {{}, ...
                    @obj.onSelectedViewOnlyProtocolPreset, ...
                    @obj.onSelectedRecordProtocolPreset, ...
                    @obj.onSelectedAddToProtocolPresetsChain}, ...
                'ColumnMinWidth', [0 40 40 40], ...
                'ColumnMaxWidth', [java.lang.Integer.MAX_VALUE 40 40 40], ...
                'Data', {}, ...
                'UserData', struct('viewOnlyEnabled', false, 'recordEnabled', false), ...
                'RowHeight', 40, ...
                'BorderType', 'none', ...
                'ShowVerticalLines', 'off', ...
                'Editable', 'off', ...
                'MouseClickedCallback', @obj.onTableMouseClicked, ...
                'CellSelectionCallback', @(h,d)notify(obj, 'SelectedProtocolPreset'));

            presetMenu = uicontextmenu('Parent', obj.figureHandle);
            uimenu( ...
                'Parent', presetMenu, ...
                'Label', 'Apply Protocol Preset', ...
                'Callback', @(h,d)notify(obj, 'ApplyProtocolPreset'));
            obj.updateMenu = uimenu( ...
                'Parent', presetMenu, ...
                'Label', 'Update Protocol Preset', ...
                'Callback', @(h,d)notify(obj, 'UpdateProtocolPreset'));
            set(obj.presetsTable, 'CellUIContextMenu', presetMenu);

            filterField = obj.presetsTable.getFilterField();
            javacomponent(filterField, [], filterLayout);
            filterField.setHintText('Type here to filter presets. Double-click a preset to apply it.');
            filterField.setColumnIndices(0);
            filterField.setDisplayNames({'Preset'});

            obj.viewOnlyButton.icon = App.getResource('icons', 'view_only.png');
            obj.viewOnlyButton.tooltip = 'View Only Protocol Preset';

            obj.recordButton.icon = App.getResource('icons', 'record.png');
            obj.recordButton.tooltip = 'Record Protocol Preset';

            obj.addToChainButton.icon = App.getResource('icons', 'chain_arrow.png');
            obj.addToChainButton.tooltip = 'Add to protocol chain';

            % Presets toolbar.
            presetsToolbarLayout = uix.HBox( ...
                'Parent', presetsTableLayout);
            obj.stopButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'stop_small.png'), ...
                'TooltipString', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'StopProtocolPreset'));
            uix.Empty('Parent', presetsToolbarLayout);
            obj.addButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'add.png'), ...
                'TooltipString', 'Add Protocol Preset...', ...
                'Callback', @(h,d)notify(obj, 'AddProtocolPreset'));
            obj.removeButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'remove.png'), ...
                'TooltipString', 'Remove Protocol Preset', ...
                'Callback', @(h,d)notify(obj, 'RemoveProtocolPreset'));
            set(presetsToolbarLayout, 'Widths', [22 -1 22 22]);

            set(presetsTableLayout, 'Height', [23 -1 22]);


            % TODO: add presets chain table
            presetsChainTableLayout = uix.VBox( ...
                'Parent', presetsLayout);

            obj.presetsChainTableLabel = Label( ...
                'Parent', presetsChainTableLayout, ...
                'String', 'Protocol Presets Chain');

            obj.presetsChainTable = uiextras.jTable.Table( ...
                'Parent', presetsChainTableLayout, ...
                'ColumnName', {'Preset', 'MoveUpChain', 'MoveDownChain', 'RemoveFromChain'}, ...
                'ColumnFormat', {'', 'button', 'button', 'button'}, ...
                'ColumnFormatData', ...
                    {{}, ...
                    @obj.onSelectedMoveUpProtocolPresetsChain, ...
                    @obj.onSelectedMoveDownProtocolPresetsChain, ...
                    @obj.onSelectedRemoveFromProtocolPresetsChain}, ...
                'ColumnMinWidth', [0 40 40 40], ...
                'ColumnMaxWidth', [java.lang.Integer.MAX_VALUE 40 40 40], ...
                'Data', {}, ...
                'UserData', struct('moveUpEnabled', false, 'moveDownEnabled', false), ...
                'RowHeight', 40, ...
                'BorderType', 'none', ...
                'ShowVerticalLines', 'off', ...
                'Editable', 'off');

            obj.moveUpChainButton.icon = App.getResource('icons', 'arrow_up_alt.png');
            obj.moveUpChainButton.tooltip = 'Move Up The Chain';

            obj.moveDownChainButton.icon = App.getResource('icons', 'arrow_down_alt.png');
            obj.moveDownChainButton.tooltip = 'Move Down The Chain';

            obj.removeFromChainButton.icon = App.getResource('icons', 'remove.png');
            obj.removeFromChainButton.tooltip = 'Remove From The Chain';

            % Presets Chain toolbar.
            presetsChainToolbarLayout = uix.HBox( ...
                'Parent', presetsChainTableLayout);
            uix.Empty('Parent', presetsChainToolbarLayout);
            obj.viewOnlyChainButton = Button( ...
                'Parent', presetsChainToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'view_only.png'), ...
                'TooltipString', 'View Only Protocol Presets Chain', ...
                'Enable', 'off', ...
                'Callback', @(h,d)notify(obj, 'ViewOnlyProtocolPresetsChain'));
            obj.recordChainButton = Button( ...
                'Parent', presetsChainToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'record.png'), ...
                'TooltipString', 'Record Protocol Presets Chain', ...
                'Enable', 'off', ...
                'Callback', @(h,d)notify(obj, 'RecordProtocolPresetsChain'));
            obj.pauseChainButton = Button( ...
                'Parent', presetsChainToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'pause.png'), ...
                'TooltipString', 'Pause Protocol Presets Chain', ...
                'Callback', @(h,d)notify(obj, 'PauseProtocolPresetsChain'));
            obj.stopChainButton = Button( ...
                'Parent', presetsChainToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons', 'stop_small.png'), ...
                'TooltipString', 'Stop Protocol Presets Chain', ...
                'Callback', @(h,d)notify(obj, 'StopProtocolPresetsChain'));
            set(presetsChainToolbarLayout, 'Widths', [-1 22 22 22 22]);
            set(presetsChainTableLayout, 'Height', [23 -1 22]);

            set(presetsLayout, 'Width', [-1 -1]);
            set(mainLayout, 'Heights', -1);
        end

        function show(obj)
            show@appbox.View(obj);
            set(obj.presetsTable, 'ColumnHeaderVisible', false);
            set(obj.presetsChainTable, 'ColumnHeaderVisible', false);
        end

        function enableViewOnlyProtocolPreset(obj, tf)                        
            data = get(obj.presetsTable, 'Data');
            for i = 1:size(data, 1)
                data{i, 2} = {obj.viewOnlyButton.icon, obj.viewOnlyButton.tooltip, tf};
            end
            set(obj.presetsTable, 'Data', data);

            enables = get(obj.presetsTable, 'UserData');
            enables.viewOnlyEnabled = tf;
            set(obj.presetsTable, 'UserData', enables);
        end
        
        function stopEditingViewOnlyProtocolPreset(obj)
            [~, editor] = obj.presetsTable.getRenderer(2);
            editor.stopCellEditing();
        end

        function enableRecordProtocolPreset(obj, tf)
            data = get(obj.presetsTable, 'Data');
            for i = 1:size(data, 1)
                data{i, 3} = {obj.recordButton.icon, obj.recordButton.tooltip, tf};
            end
            set(obj.presetsTable, 'Data', data);

            enables = get(obj.presetsTable, 'UserData');
            enables.recordEnabled = tf;
            set(obj.presetsTable, 'UserData', enables);
        end
        
        function stopEditingRecordProtocolPreset(obj)
            [~, editor] = obj.presetsTable.getRenderer(3);
            editor.stopCellEditing();
        end

        function enableStopProtocolPreset(obj, tf)
            set(obj.stopButton, 'Enable', appbox.onOff(tf));
        end

        function enableViewOnlyProtocolPresetsChain(obj, tf)
            data = get(obj.presetsChainTable, 'Data');
            tf = (size(data, 1) > 0) && tf;
            set(obj.viewOnlyChainButton, 'Enable', appbox.onOff(tf));
        end

        function enableRecordProtocolPresetsChain(obj, tf)
            data = get(obj.presetsChainTable, 'Data');
            tf = (size(data, 1) > 0) && tf;
            set(obj.recordChainButton, 'Enable', appbox.onOff(tf));
        end

        function enableStopProtocolPresetsChain(obj, tf)
            set(obj.stopChainButton, 'Enable', appbox.onOff(tf));
        end

        function enablePauseProtocolPresetChain(obj, tf)
            set(obj.pauseChainButton, 'Enable', appbox.onOff(tf));
        end

        function setProtocolPresets(obj, data)
            enables = get(obj.presetsTable, 'UserData');
            d = cell(size(data, 1), 4);
            for i = 1:size(d, 1)
                d{i, 1} = toDisplayName(data{i, 1}, data{i, 2});
                d{i, 2} = {obj.viewOnlyButton.icon, obj.viewOnlyButton.tooltip, enables.viewOnlyEnabled};
                d{i, 3} = {obj.recordButton.icon, obj.recordButton.tooltip, enables.recordEnabled};
                d{i, 4} = {obj.addToChainButton.icon, obj.addToChainButton.tooltip, true};
            end
            set(obj.presetsTable, 'Data', d);
        end

        function d = getProtocolPresets(obj)
            presets = obj.presetsTable.getColumnData(1);
            d = cell(numel(presets), 2);
            for i = 1:size(d, 1)
                [name, protocolId] = fromDisplayName(presets{i});
                d{i, 1} = name;
                d{i, 2} = protocolId;
            end
        end

        function d = getProtocolPresetsChain(obj)
            presets = obj.presetsChainTable.getColumnData(1);
            d = cell(numel(presets), 2);
            for i = 1:size(d, 1)
                [name, protocolId] = fromDisplayName(presets{i});
                d{i, 1} = name;
                d{i, 2} = protocolId;
            end
        end
        
        function enableAddProtocolPreset(obj, tf)
            set(obj.addButton, 'Enable', appbox.onOff(tf));
        end

        function addProtocolPreset(obj, name, protocolId)
            enables = get(obj.presetsTable, 'UserData');
            obj.presetsTable.addRow({toDisplayName(name, protocolId), ...
                {obj.viewOnlyButton.icon, obj.viewOnlyButton.tooltip, enables.viewOnlyEnabled}, ...
                {obj.recordButton.icon, obj.recordButton.tooltip, enables.recordEnabled}, ...
                {obj.addToChainButton.icon, obj.addToChainButton.tooltip, true}});
        end

        function removeProtocolPreset(obj, name)
            presets = obj.presetsTable.getColumnData(1);
            index = find(cellfun(@(c)strcmp(fromDisplayName(c), name), presets));
            obj.presetsTable.removeRow(index); %#ok<FNDSB>
        end
        
        function enableUpdateProtocolPreset(obj, tf)
            set(obj.updateMenu, 'Enable', appbox.onOff(tf));
        end

        function [name, id] = getSelectedProtocolPreset(obj)
            srows = get(obj.presetsTable, 'SelectedRows');
            rows = obj.presetsTable.getActualRowsAt(srows);
            if isempty(rows)
                name = [];
                id = [];
            else
                [name, id] = fromDisplayName(obj.presetsTable.getValueAt(rows(1), 1));
            end
        end

        function setSelectedProtocolPreset(obj, name)
            presets = obj.presetsTable.getColumnData(1);
            index = find(cellfun(@(c)strcmp(fromDisplayName(c), name), presets));
            sindex = obj.presetsTable.getVisualRowsAt(index); %#ok<FNDSB>
            set(obj.presetsTable, 'SelectedRows', sindex);
        end

    end
    
    methods (Access = private)
        
        function onSelectedViewOnlyProtocolPreset(obj, ~, event)
            src = event.getSource();
            data.getEditingRow = @()obj.presetsTable.getActualRowsAt(src.getEditingRow() + 1);
            notify(obj, 'ViewOnlyProtocolPreset', symphonyui.ui.UiEventData(data))
        end
        
        function onSelectedRecordProtocolPreset(obj, ~, event)
            src = event.getSource();
            data.getEditingRow = @()obj.presetsTable.getActualRowsAt(src.getEditingRow() + 1);
            notify(obj, 'RecordProtocolPreset', symphonyui.ui.UiEventData(data))
        end

        function onSelectedAddToProtocolPresetsChain(obj, ~, event)
            src = event.getSource();
            data.getEditingRow = @()obj.presetsTable.getActualRowsAt(src.getEditingRow() + 1);
            % TODO: add the selected preset to obj.presetsChainTable
            presets = obj.getProtocolPresets();
            [name, protocolId] = presets{data.getEditingRow(), :};
            moveUpEnabled = true;
            addingFirstRow = false;
            if isempty(obj.presetsChainTable.Data) % adding first row
                moveUpEnabled = false;
                addingFirstRow = true;
            else
                % enable last row's moveDownButton status
                lastRowNumber = size(obj.presetsChainTable.Data, 1);
                obj.setMoveDownButtonEnableStatus(lastRowNumber, true);
            end
            obj.presetsChainTable.addRow({toDisplayName(name, protocolId), ...
                {obj.moveUpChainButton.icon, obj.moveUpChainButton.tooltip, moveUpEnabled}, ...
                {obj.moveDownChainButton.icon, obj.moveDownChainButton.tooltip, false}, ...
                {obj.removeFromChainButton.icon, obj.removeFromChainButton.tooltip, true}});

            if addingFirstRow
                notify(obj, 'UpdateProtocolPresetsChain'); % enable 'View Only / Record Chain Buttons'
            end
        end

        function onTableMouseClicked(obj, ~, event)
            if event.ClickCount == 2
                notify(obj, 'ApplyProtocolPreset');
            end
        end

        function onChainTableMouseClicked(obj, ~, event)
            if event.ClickCount == 2
                % TODO: add something to do, if required;
            end
        end

        function onSelectedMoveUpProtocolPresetsChain(obj, ~, event)
            src = event.getSource();
            data.getEditingRow = @()obj.presetsChainTable.getActualRowsAt(src.getEditingRow() + 1);
            % swap positions of selected and selected-1 rows
            selectedRowNumber = data.getEditingRow();
            upperRowNumber = selectedRowNumber - 1;
            obj.swapPresetsChainTableRows(selectedRowNumber, upperRowNumber);
        end

        function onSelectedMoveDownProtocolPresetsChain(obj, ~, event)
            src = event.getSource();
            data.getEditingRow = @()obj.presetsChainTable.getActualRowsAt(src.getEditingRow() + 1);
            % swap positions of selected and selected+1 rows
            selectedRowNumber = data.getEditingRow();
            lowerRowNumber = selectedRowNumber + 1;
            obj.swapPresetsChainTableRows(selectedRowNumber, lowerRowNumber);
        end

        function onSelectedRemoveFromProtocolPresetsChain(obj, ~, event)
            src = event.getSource();
            data.getEditingRow = @()obj.presetsChainTable.getActualRowsAt(src.getEditingRow() + 1);

            selectedRowNumber = data.getEditingRow();
            numberOfRows = size(obj.presetsChainTable.Data, 1);
            if numberOfRows > 1
                if selectedRowNumber == 1
                    obj.setMoveUpButtonEnableStatus(selectedRowNumber+1, false);
                elseif selectedRowNumber == numberOfRows
                    obj.setMoveDownButtonEnableStatus(selectedRowNumber-1, false);
                end
            end
            obj.presetsChainTable.Data(selectedRowNumber, :) = [];
            if isempty(obj.presetsChainTable.Data)
                notify(obj, 'UpdateProtocolPresetsChain'); % disable 'View Only / Record Chain Buttons'
            end
        end

        function swapPresetsChainTableRows(obj, firstRowNumber, secondRowNumber)
            % swap moveUpButton enabled status
            tempMoveUpButtonStatus = obj.getMoveUpButtonEnableStatus(firstRowNumber);
            obj.setMoveUpButtonEnableStatus(firstRowNumber, obj.getMoveUpButtonEnableStatus(secondRowNumber));
            obj.setMoveUpButtonEnableStatus(secondRowNumber, tempMoveUpButtonStatus);
            % swap moveDownButton enabled status
            tempMoveDownButtonStatus = obj.getMoveDownButtonEnableStatus(firstRowNumber);
            obj.setMoveDownButtonEnableStatus(firstRowNumber, obj.getMoveDownButtonEnableStatus(secondRowNumber));
            obj.setMoveDownButtonEnableStatus(secondRowNumber, tempMoveDownButtonStatus);
            % swap positions of first and second rows
            tempRow = obj.presetsChainTable.Data(firstRowNumber, :);
            obj.presetsChainTable.Data(firstRowNumber, :) = obj.presetsChainTable.Data(secondRowNumber, :);
            obj.presetsChainTable.Data(secondRowNumber, :) = tempRow;
        end

        function tf = getMoveUpButtonEnableStatus(obj, rowNumber)
            tf = obj.presetsChainTable.Data{rowNumber, 2}{3};
        end

        function setMoveUpButtonEnableStatus(obj, rowNumber, tf)
            obj.presetsChainTable.Data{rowNumber, 2}{3} = tf;
        end

        function tf = getMoveDownButtonEnableStatus(obj, rowNumber)
            tf = obj.presetsChainTable.Data{rowNumber, 3}{3};
        end

        function setMoveDownButtonEnableStatus(obj, rowNumber, tf)
            obj.presetsChainTable.Data{rowNumber, 3}{3} = tf;
        end

        function onSelectedViewOnlyProtocolPresetsChain(obj, ~, event)
            src = event.getSource();
            data.getEditingRow = @()obj.presetsChainTable.getActualRowsAt(src.getEditingRow() + 1);
            notify(obj, 'ViewOnlyProtocolPresetsChain', symphonyui.ui.UiEventData(data))
        end

        function onSelectedRecordProtocolPresetsChain(obj, ~, event)
            src = event.getSource();
            data.getEditingRow = @()obj.presetsChainTable.getActualRowsAt(src.getEditingRow() + 1);
            notify(obj, 'RecordProtocolPresetsChain', symphonyui.ui.UiEventData(data))
        end

    end

end

function html = toDisplayName(name, protocolId)
    html = ['<html>' name '<br><font color="gray">' protocolId '</font></html>'];
end

function [name, protocolId] = fromDisplayName(html)
    split = regexprep(html, '<br>', '\n');
    split = regexprep(split, '<.*?>', '');
    split = strsplit(split, '\n');
    name = split{1};
    protocolId = split{2};
end
