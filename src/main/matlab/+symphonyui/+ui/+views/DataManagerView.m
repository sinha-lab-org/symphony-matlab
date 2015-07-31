classdef DataManagerView < symphonyui.ui.View

    events
        AddSource
        BeginEpochGroup
        EndEpochGroup
        SelectedNodes
        SetSourceLabel
        SetExperimentPurpose
        SetEpochGroupLabel
        AddProperty
        SetProperty
        RemoveProperty
        AddKeyword
        RemoveKeyword
        AddNote
        SendToWorkspace
        DeleteEntity
        Refresh
        OpenAxesInNewWindow
    end

    properties (Access = private)
        addSourceButtons
        beginEpochGroupButtons
        endEpochGroupButtons
        refreshButtons
        entityTree
        devicesFolderNode
        sourcesFolderNode
        epochGroupsFolderNode
        detailLayout
        dataCardPanel
        emptyCard
        deviceCard
        sourceCard
        experimentCard
        epochGroupCard
        epochBlockCard
        epochCard
        tabGroup
        propertiesTab
        keywordsTab
        notesTab
        parametersTab
    end
    
    properties (Constant)
        EMPTY_CARD         = 1
        DEVICE_CARD        = 2
        SOURCE_CARD        = 3
        EXPERIMENT_CARD    = 4
        EPOCH_GROUP_CARD   = 5
        EPOCH_BLOCK_CARD   = 6
        EPOCH_CARD         = 7
    end
    
    methods

        function createUi(obj)
            import symphonyui.ui.util.*;
            import symphonyui.ui.views.EntityNodeType;

            set(obj.figureHandle, ...
                'Name', 'Data Manager', ...
                'Position', screenCenter(502, 375));

            % Toolbar.
            toolbar = uitoolbar( ...
                'Parent', obj.figureHandle);
            obj.addSourceButtons.tool = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'Add Source...', ...
                'ClickedCallback', @(h,d)notify(obj, 'AddSource'));
            setIconImage(obj.addSourceButtons.tool, symphonyui.app.App.getResource('icons/source_add.png'));
            obj.beginEpochGroupButtons.tool = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'Begin Epoch Group...', ...
                'Separator', 'on', ...
                'ClickedCallback', @(h,d)notify(obj, 'BeginEpochGroup'));
            setIconImage(obj.beginEpochGroupButtons.tool, symphonyui.app.App.getResource('icons/group_begin.png'));
            obj.endEpochGroupButtons.tool = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'End Epoch Group', ...
                'ClickedCallback', @(h,d)notify(obj, 'EndEpochGroup'));
            setIconImage(obj.endEpochGroupButtons.tool, symphonyui.app.App.getResource('icons/group_end.png'));

            mainLayout = uix.HBoxFlex( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);

            masterLayout = uix.VBoxFlex( ...
                'Parent', mainLayout, ...
                'Spacing', 7);

            obj.entityTree = uiextras.jTree.Tree( ...
                'Parent', masterLayout, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'SelectionChangeFcn', @(h,d)notify(obj, 'SelectedNodes'), ...
                'SelectionType', 'discontiguous');
            
            treeMenu = uicontextmenu('Parent', obj.figureHandle);
            obj.addSourceButtons.menu = uimenu( ...
                'Parent', treeMenu, ...
                'Label', 'Add Source...', ...
                'Callback', @(h,d)notify(obj, 'AddSource'));
            obj.beginEpochGroupButtons.menu = uimenu( ...
                'Parent', treeMenu, ...
                'Label', 'Begin Epoch Group...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'BeginEpochGroup'));
            obj.endEpochGroupButtons.menu = uimenu( ...
                'Parent', treeMenu, ...
                'Label', 'End Epoch Group', ...
                'Callback', @(h,d)notify(obj, 'EndEpochGroup'));
            obj.refreshButtons.menu = uimenu( ...
                'Parent', treeMenu, ...
                'Label', 'Refresh', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'Refresh'));
            set(obj.entityTree, 'UIContextMenu', treeMenu);
            
            root = obj.entityTree.Root;
            set(root, 'Value', struct('entity', [], 'type', EntityNodeType.EXPERIMENT));
            root.setIcon(symphonyui.app.App.getResource('icons/experiment.png'));
            set(root, 'UIContextMenu', obj.createEntityContextMenu());
            
            devices = uiextras.jTree.TreeNode( ...
                'Parent', root, ...
                'Name', 'Devices', ...
                'Value', struct('entity', [], 'type', EntityNodeType.FOLDER));
            devices.setIcon(symphonyui.app.App.getResource('icons/folder.png'));
            obj.devicesFolderNode = devices;

            sources = uiextras.jTree.TreeNode( ...
                'Parent', root, ...
                'Name', 'Sources', ...
                'Value', struct('entity', [], 'type', EntityNodeType.FOLDER));
            sources.setIcon(symphonyui.app.App.getResource('icons/folder.png'));
            obj.sourcesFolderNode = sources;

            groups = uiextras.jTree.TreeNode( ...
                'Parent', root, ...
                'Name', 'Epoch Groups', ...
                'Value', struct('entity', [], 'type', EntityNodeType.FOLDER));
            groups.setIcon(symphonyui.app.App.getResource('icons/folder.png'));
            obj.epochGroupsFolderNode = groups;

            obj.detailLayout = uix.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            obj.dataCardPanel = uix.CardPanel( ...
                'Parent', obj.detailLayout);
            
            % Empty card.
            obj.emptyCard.layout = uix.VBox( ...
                'Parent', obj.dataCardPanel);
            uix.Empty('Parent', obj.emptyCard.layout);
            obj.emptyCard.text = uicontrol( ...
                'Parent', obj.emptyCard.layout, ...
                'Style', 'text', ...
                'HorizontalAlignment', 'center');
            uix.Empty('Parent', obj.emptyCard.layout);
            set(obj.emptyCard.layout, ...
                'Heights', [-1 25 -1], ...
                'UserData', struct('Height', -1));
            
            % Device card.
            obj.deviceCard.layout = uix.Grid( ...
                'Parent', obj.dataCardPanel, ...
                'Spacing', 7);
            Label( ...
                'Parent', obj.deviceCard.layout, ...
                'String', 'Name:');
            Label( ...
                'Parent', obj.deviceCard.layout, ...
                'String', 'Manufacturer:');
            obj.deviceCard.nameField = uicontrol( ...
                'Parent', obj.deviceCard.layout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.deviceCard.manufacturerField = uicontrol( ...
                'Parent', obj.deviceCard.layout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(obj.deviceCard.layout, ...
                'Widths', [80 -1], ...
                'Heights', [25 25], ...
                'UserData', struct('Height', 25*2+7*1));
            
            % Source card.
            obj.sourceCard.layout = uix.Grid( ...
                'Parent', obj.dataCardPanel, ...
                'Spacing', 7);
            Label( ...
                'Parent', obj.sourceCard.layout, ...
                'String', 'Label:');
            obj.sourceCard.labelField = uicontrol( ...
                'Parent', obj.sourceCard.layout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SetSourceLabel'));
            set(obj.sourceCard.layout, ...
                'Widths', [35 -1], ...
                'Heights', 25, ...
                'UserData', struct('Height', 25*1+7*0));

            % Experiment card.
            obj.experimentCard.layout = uix.Grid( ...
                'Parent', obj.dataCardPanel, ...
                'Spacing', 7);
            Label( ...
                'Parent', obj.experimentCard.layout, ...
                'String', 'Purpose:');
            Label( ...
                'Parent', obj.experimentCard.layout, ...
                'String', 'Start time:');
            Label( ...
                'Parent', obj.experimentCard.layout, ...
                'String', 'End time:');
            obj.experimentCard.purposeField = uicontrol( ...
                'Parent', obj.experimentCard.layout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SetExperimentPurpose'));
            obj.experimentCard.startTimeField = uicontrol( ...
                'Parent', obj.experimentCard.layout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.experimentCard.endTimeField = uicontrol( ...
                'Parent', obj.experimentCard.layout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(obj.experimentCard.layout, ...
                'Widths', [60 -1], ...
                'Heights', [25 25 25], ...
                'UserData', struct('Height', 25*3+7*2));

            % Epoch group card.
            obj.epochGroupCard.layout = uix.Grid( ...
                'Parent', obj.dataCardPanel, ...
                'Spacing', 7);
            Label( ...
                'Parent', obj.epochGroupCard.layout, ...
                'String', 'Label:');
            Label( ...
                'Parent', obj.epochGroupCard.layout, ...
                'String', 'Start time:');
            Label( ...
                'Parent', obj.epochGroupCard.layout, ...
                'String', 'End time:');
            Label( ...
                'Parent', obj.epochGroupCard.layout, ...
                'String', 'Source:');
            obj.epochGroupCard.labelField = uicontrol( ...
                'Parent', obj.epochGroupCard.layout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(h,d)notify(obj, 'SetEpochGroupLabel'));
            obj.epochGroupCard.startTimeField = uicontrol( ...
                'Parent', obj.epochGroupCard.layout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.epochGroupCard.endTimeField = uicontrol( ...
                'Parent', obj.epochGroupCard.layout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.epochGroupCard.sourceField = uicontrol( ...
                'Parent', obj.epochGroupCard.layout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(obj.epochGroupCard.layout, ...
                'Widths', [60 -1], ...
                'Heights', [25 25 25 25], ...
                'UserData', struct('Height', 25*4+7*3));
            
            % Epoch block card.
            obj.epochBlockCard.layout = uix.Grid( ...
                'Parent', obj.dataCardPanel, ...
                'Spacing', 7);
            Label( ...
                'Parent', obj.epochBlockCard.layout, ...
                'String', 'Protocol ID:');
            Label( ...
                'Parent', obj.epochBlockCard.layout, ...
                'String', 'Start time:');
            Label( ...
                'Parent', obj.epochBlockCard.layout, ...
                'String', 'End time:');
            obj.epochBlockCard.protocolIdField = uicontrol( ...
                'Parent', obj.epochBlockCard.layout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.epochBlockCard.startTimeField = uicontrol( ...
                'Parent', obj.epochBlockCard.layout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            obj.epochBlockCard.endTimeField = uicontrol( ...
                'Parent', obj.epochBlockCard.layout, ...
                'Style', 'edit', ...
                'Enable', 'off', ...
                'HorizontalAlignment', 'left');
            set(obj.epochBlockCard.layout, ...
                'Widths', [65 -1], ...
                'Heights', [25 25 25], ...
                'UserData', struct('Height', 25*3+7*2));
            
            % Epoch card.
            obj.epochCard.layout = uix.VBox( ...
                'Parent', obj.dataCardPanel, ...
                'Spacing', 7);
            obj.epochCard.panel = uipanel( ...
                'Parent', obj.epochCard.layout, ...
                'BorderType', 'line', ...
                'HighlightColor', [130/255 135/255 144/255], ...
                'BackgroundColor', 'w');
            obj.epochCard.axes = axes( ...
                'Parent', obj.epochCard.panel, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
            axesMenu = uicontextmenu('Parent', obj.figureHandle);
            uimenu( ...
                'Parent', axesMenu, ...
                'Label', 'Open in new window', ...
                'Callback', @(h,d)notify(obj, 'OpenAxesInNewWindow'));
            set(obj.epochCard.axes, 'UIContextMenu', axesMenu);
            set(obj.epochCard.panel, 'UIContextMenu', axesMenu);
            set(obj.epochCard.layout, ...
                'Heights', -1, ...
                'UserData', struct('Height', -1));
            
            % Tab group.
            obj.tabGroup = TabGroup( ...
                'Parent', obj.detailLayout);

            % Properties tab.
            obj.propertiesTab.tab = uitab( ...
                'Parent', [], ...
                'Title', 'Properties');
            obj.tabGroup.addTab(obj.propertiesTab.tab);
            obj.propertiesTab.layout = uix.VBox( ...
                'Parent', obj.propertiesTab.tab);
            obj.propertiesTab.grid = uiextras.jide.PropertyGrid(obj.propertiesTab.layout, ...
                'BorderType', 'none', ...
                'Callback', @(h,d)notify(obj, 'SetProperty', d));
            [a, r] = obj.createAddRemoveButtons(obj.propertiesTab.layout, @(h,d)notify(obj, 'AddProperty'), @(h,d)notify(obj, 'RemoveProperty'));
            obj.propertiesTab.addButton = a;
            obj.propertiesTab.removeButton = r;
            set(obj.propertiesTab.layout, 'Heights', [-1 25]);

            % Keywords tab.
            obj.keywordsTab.tab = uitab( ...
                'Parent', [], ...
                'Title', 'Keywords');
            obj.tabGroup.addTab(obj.keywordsTab.tab);
            obj.keywordsTab.layout = uix.VBox( ...
                'Parent', obj.keywordsTab.tab);
            obj.keywordsTab.table = Table( ...
                'Parent', obj.keywordsTab.layout, ...
                'ColumnName', {'Keyword'}, ...
                'Editable', false);
            [a, r] = obj.createAddRemoveButtons(obj.keywordsTab.layout, @(h,d)notify(obj, 'AddKeyword'), @(h,d)notify(obj, 'RemoveKeyword'));
            obj.keywordsTab.addButton = a;
            obj.keywordsTab.removeButton = r;
            set(obj.keywordsTab.layout, 'Heights', [-1 25]);

            % Notes tab.
            obj.notesTab.tab = uitab( ...
                'Parent', [], ...
                'Title', 'Notes');
            obj.tabGroup.addTab(obj.notesTab.tab);
            obj.notesTab.layout = uix.VBox( ...
                'Parent', obj.notesTab.tab);
            obj.notesTab.table = Table( ...
                'Parent', obj.notesTab.layout, ...
                'ColumnName', {'Time', 'Text'}, ...
                'ColumnWidth', {80}, ...
                'Editable', false);
            [a, r] = obj.createAddRemoveButtons(obj.notesTab.layout, @(h,d)notify(obj, 'AddNote'), []);
            obj.notesTab.addButton = a;
            obj.notesTab.removeButton = r;
            set(obj.notesTab.removeButton, 'Enable', 'off');
            set(obj.notesTab.layout, 'Heights', [-1 25]);
            
            % Parameters tab.
            obj.parametersTab.tab = uitab( ...
                'Parent', [], ...
                'Title', 'Parameters');
            obj.tabGroup.addTab(obj.parametersTab.tab);

            set(mainLayout, 'Widths', [-1 -1.75]);
        end
        
        function enableBeginEpochGroup(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.beginEpochGroupButtons.tool, 'Enable', enable);
            set(obj.beginEpochGroupButtons.menu, 'Enable', enable);
        end

        function enableEndEpochGroup(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.endEpochGroupButtons.tool, 'Enable', enable);
            set(obj.endEpochGroupButtons.menu, 'Enable', enable);
        end
        
        function setCardSelection(obj, index)
            set(obj.dataCardPanel, 'Selection', index);
            
            tabGroupHeight = -1;
            switch index
                case obj.EMPTY_CARD
                    u = get(obj.emptyCard.layout, 'UserData');
                    tabGroupHeight = 0;
                case obj.DEVICE_CARD
                    u = get(obj.deviceCard.layout, 'UserData');
                case obj.SOURCE_CARD
                    u = get(obj.sourceCard.layout, 'UserData');
                case obj.EXPERIMENT_CARD
                    u = get(obj.experimentCard.layout, 'UserData');
                case obj.EPOCH_GROUP_CARD
                    u = get(obj.epochGroupCard.layout, 'UserData');
                case obj.EPOCH_BLOCK_CARD
                    u = get(obj.epochBlockCard.layout, 'UserData');
                case obj.EPOCH_CARD
                    u = get(obj.epochCard.layout, 'UserData');
            end
            set(obj.detailLayout, 'Heights', [u.Height tabGroupHeight]);
            
            if index == obj.EPOCH_CARD
                obj.tabGroup.addTab(obj.parametersTab.tab);
            else
                obj.tabGroup.removeTab(obj.parametersTab.tab);
            end
        end
        
        function setEmptyText(obj, t)
            set(obj.emptyCard.text, 'String', t);
        end
        
        function n = getDevicesFolderNode(obj)
            n = obj.devicesFolderNode;
        end

        function n = addDeviceNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.DEVICE;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons/device.png'));
            set(n, 'UIContextMenu', obj.createEntityContextMenu());
        end

        function setDeviceName(obj, n)
            set(obj.deviceCard.nameField, 'String', n);
        end
        
        function setDeviceManufacturer(obj, m)
            set(obj.deviceCard.manufacturerField, 'String', m);
        end
        
        function n = getSourcesFolderNode(obj)
            n = obj.sourcesFolderNode;
        end

        function n = addSourceNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.SOURCE;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons/source.png'));
            set(n, 'UIContextMenu', obj.createEntityContextMenu());
        end
        
        function enableSourceLabel(obj, tf)
            set(obj.sourceCard.labelField, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function l = getSourceLabel(obj)
            l = get(obj.sourceCard.labelField, 'String');
        end
        
        function setSourceLabel(obj, l)
            set(obj.sourceCard.labelField, 'String', l);
        end

        function setExperimentNode(obj, name, entity)
            value = get(obj.entityTree.Root, 'Value');
            value.entity = entity;
            set(obj.entityTree.Root, ...
                'Name', name, ...
                'Value', value);
        end
        
        function n = getExperimentNode(obj)
            n = obj.entityTree.Root;
        end
        
        function enableExperimentPurpose(obj, tf)
            set(obj.experimentCard.purposeField, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function p = getExperimentPurpose(obj)
            p = get(obj.experimentCard.purposeField, 'String');
        end

        function setExperimentPurpose(obj, p)
            set(obj.experimentCard.purposeField, 'String', p);
        end
        
        function setExperimentStartTime(obj, t)
            set(obj.experimentCard.startTimeField, 'String', t);
        end
        
        function setExperimentEndTime(obj, t)
            set(obj.experimentCard.endTimeField, 'String', t);
        end
        
        function n = getEpochGroupsFolderNode(obj)
            n = obj.epochGroupsFolderNode;
        end

        function n = addEpochGroupNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.EPOCH_GROUP;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons/group.png'));
            set(n, 'UIContextMenu', obj.createEntityContextMenu());
        end
        
        function enableEpochGroupLabel(obj, tf)
            set(obj.epochGroupCard.labelField, 'Enable', symphonyui.ui.util.onOff(tf));
        end
        
        function l = getEpochGroupLabel(obj)
            l = get(obj.epochGroupCard.labelField, 'String');
        end

        function setEpochGroupLabel(obj, l)
            set(obj.epochGroupCard.labelField, 'String', l);
        end

        function setEpochGroupStartTime(obj, t)
            set(obj.epochGroupCard.startTimeField, 'String', t);
        end

        function setEpochGroupEndTime(obj, t)
            set(obj.epochGroupCard.endTimeField, 'String', t);
        end

        function setEpochGroupSource(obj, s)
            set(obj.epochGroupCard.sourceField, 'String', s);
        end

        function setEpochGroupNodeCurrent(obj, node) %#ok<INUSL>
            node.setIcon(symphonyui.app.App.getResource('icons/group_current.png'));
        end

        function setEpochGroupNodeNormal(obj, node) %#ok<INUSL>
            node.setIcon(symphonyui.app.App.getResource('icons/group.png'));
        end
        
        function n = addEpochBlockNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.EPOCH_BLOCK;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons/block.png'));
            set(n, 'UIContextMenu', obj.createEntityContextMenu());
        end
        
        function setEpochBlockProtocolId(obj, i)
            set(obj.epochBlockCard.protocolIdField, 'String', i);
        end
        
        function setEpochBlockStartTime(obj, t)
            set(obj.epochBlockCard.startTimeField, 'String', t);
        end

        function setEpochBlockEndTime(obj, t)
            set(obj.epochBlockCard.endTimeField, 'String', t);
        end

        function n = addEpochNode(obj, parent, name, entity)
            value.entity = entity;
            value.type = symphonyui.ui.views.EntityNodeType.EPOCH;
            n = uiextras.jTree.TreeNode( ...
                'Parent', parent, ...
                'Name', name, ...
                'Value', value);
            n.setIcon(symphonyui.app.App.getResource('icons/epoch.png'));
            set(n, 'UIContextMenu', obj.createEntityContextMenu());
        end
        
        function clearEpochDataAxes(obj)
            cla(obj.epochCard.axes);
        end
        
        function setEpochDataAxesLabels(obj, x, y)
            xlabel(obj.epochCard.axes, x, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
            ylabel(obj.epochCard.axes, y, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'));
        end
        
        function addEpochDataLine(obj, x, y, color)
            line(x, y, 'Parent', obj.epochCard.axes, 'Color', color);
        end
        
        function setEpochDataLegend(obj, labels, groups)
            clickableLegend(obj.epochCard.axes, labels{:}, 'groups', groups);
        end
        
        function openEpochDataAxesInNewWindow(obj)
            fig = figure( ...
                'MenuBar', 'figure', ...
                'Toolbar', 'figure', ...
                'Visible', 'off');
            axes = copyobj(obj.epochCard.axes, fig);
            set(axes, ...
                'Units', 'normalized', ...
                'Position', get(groot, 'defaultAxesPosition'));
            set(fig, 'Visible', 'on');
        end
        
        function setEpochProtocolParameters(obj, data)
            set(obj.epochCard.table, 'Data', data);
        end
        
        function n = getNodeName(obj, node) %#ok<INUSL>
            n = get(node, 'Name');
        end
        
        function setNodeName(obj, node, name) %#ok<INUSL>
            set(node, 'Name', name);
        end
        
        function e = getNodeEntity(obj, node) %#ok<INUSL>
            v = get(node, 'Value');
            e = v.entity;
        end
        
        function t = getNodeType(obj, node) %#ok<INUSL>
            v = get(node, 'Value');
            t = v.type;
        end
        
        function removeNode(obj, node) %#ok<INUSL>
            node.delete();
        end

        function collapseNode(obj, node) %#ok<INUSL>
            node.collapse();
        end

        function expandNode(obj, node) %#ok<INUSL>
            node.expand();
        end

        function nodes = getSelectedNodes(obj)
            nodes = obj.entityTree.SelectedNodes;
        end

        function setSelectedNodes(obj, nodes)
            obj.entityTree.SelectedNodes = nodes;
        end
        
        function enableProperties(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.propertiesTab.addButton, 'Enable', enable);
            set(obj.propertiesTab.removeButton, 'Enable', enable);
        end

        function setProperties(obj, properties)
            set(obj.propertiesTab.grid, 'Properties', properties);
        end
        
        function p = getProperties(obj)
            p = get(obj.propertiesTab.grid, 'Properties');
        end

        function addProperty(obj, key, value)
            %obj.propertiesTab.table.addRow({key, value});
        end

        function removeProperty(obj, property)
            %properties = obj.propertiesTab.table.getColumnData(1);
            %index = find(cellfun(@(c)strcmp(c, property), properties));
            %obj.propertiesTab.table.removeRow(index); %#ok<FNDSB>
        end

        function p = getSelectedProperty(obj)
            row = get(obj.propertiesTab.table, 'SelectedRow');
            p = obj.propertiesTab.table.getValueAt(row, 1);
        end
        
        function enableKeywords(obj, tf)
            enable = symphonyui.ui.util.onOff(tf);
            set(obj.keywordsTab.addButton, 'Enable', enable);
            set(obj.keywordsTab.removeButton, 'Enable', enable);
        end

        function setKeywords(obj, data)
            set(obj.keywordsTab.table, 'Data', data);
        end

        function addKeyword(obj, keyword)
            obj.keywordsTab.table.addRow(keyword);
        end

        function removeKeyword(obj, keyword)
            keywords = obj.keywordsTab.table.getColumnData(1);
            index = find(cellfun(@(c)strcmp(c, keyword), keywords));
            obj.keywordsTab.table.removeRow(index); %#ok<FNDSB>
        end

        function k = getSelectedKeyword(obj)
            row = get(obj.keywordsTab.table, 'SelectedRow');
            k = obj.keywordsTab.table.getValueAt(row, 1);
        end
        
        function enableNotes(obj, tf)
            set(obj.notesTab.addButton, 'Enable', symphonyui.ui.util.onOff(tf));
        end

        function setNotes(obj, data)
            set(obj.notesTab.table, 'Data', data);
        end

        function addNote(obj, date, text)
            obj.notesTab.table.addRow({date, text});
        end

    end

    methods (Access = private)

        function [addButton, removeButton] = createAddRemoveButtons(obj, parent, addCallback, removeCallback)
            layout = uix.HBox( ...
                'Parent', parent, ...
                'BackgroundColor', 'w');
            uix.Empty('Parent', layout);
            addButton = uicontrol( ...
                'Parent', layout, ...
                'Style', 'pushbutton', ...
                'String', '+', ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize') + 1, ...
                'Callback', addCallback);
            removeButton = uicontrol( ...
                'Parent', layout, ...
                'Style', 'pushbutton', ...
                'String', '-', ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize') + 1, ...
                'Callback', removeCallback);
            uix.Empty('Parent', layout);
            set(layout, 'Widths', [-1 25 25 1]);
        end
        
        function menu = createEntityContextMenu(obj)
            menu = uicontextmenu('Parent', obj.figureHandle);
            m.sendToWorkspaceMenu = uimenu( ...
                'Parent', menu, ...
                'Label', 'Send to Workspace', ...
                'Callback', @(h,d)notify(obj, 'SendToWorkspace'));
            m.deleteMenu = uimenu( ...
                'Parent', menu, ...
                'Label', 'Delete', ...
                'Callback', @(h,d)notify(obj, 'DeleteEntity'));
            set(menu, 'UserData', m);
        end

    end

end
