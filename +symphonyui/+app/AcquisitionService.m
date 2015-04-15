classdef AcquisitionService < handle

    events (NotifyAccess = private)
        OpenedExperiment
        ClosedExperiment
        SelectedProtocol
    end

    properties (Access = private)
        experimentFactory
        protocolDescriptorRepository
    end

    properties (Access = private)
        session
    end

    properties (Constant, Access = private)
        NONE_ID = '(None)';
    end

    methods

        function obj = AcquisitionService(experimentFactory, protocolDescriptorRepository)
            obj.experimentFactory = experimentFactory;
            obj.protocolDescriptorRepository = protocolDescriptorRepository;
            obj.session.rig = symphonyui.core.Rig();
            
            % Try to start with a non-null protocol. Otherwise just start with the null protocol selected.
            ids = obj.protocolDescriptorRepository.getAllIds();
            try %#ok<TRYNC>
                obj.selectProtocol(ids{1});
            end
        end

        function delete(obj)
            if ~isempty(obj.getCurrentExperiment())
                obj.closeExperiment();
            end
        end
        
        function r = getRig(obj)
            r = obj.session.rig;
        end

        %% Experiment

        function createExperiment(obj, name, location, purpose)
            if obj.hasCurrentExperiment()
                error('An experiment is already open');
            end
            experiment = obj.experimentFactory.create(name, location, purpose);
            experiment.open();
            obj.session.experiment = experiment;
            notify(obj, 'OpenedExperiment');
        end

        function openExperiment(obj, path)
            if obj.hasCurrentExperiment()
                error('An experiment is already open');
            end
            experiment = obj.experimentFactory.open(path);
            obj.session.experiment = experiment;
            notify(obj, 'OpenedExperiment');
        end

        function closeExperiment(obj)
            if ~obj.hasCurrentExperiment()
                error('No experiment open');
            end
            obj.session.experiment.close();
            obj.session.experiment = [];
            notify(obj, 'ClosedExperiment');
        end

        function tf = hasCurrentExperiment(obj)
            tf = ~isempty(obj.getCurrentExperiment());
        end

        function e = getCurrentExperiment(obj)
            e = [];
            if isfield(obj.session, 'experiment')
                e = obj.session.experiment;
            end
        end

        %% Protocol

        function i = getAvailableProtocolIds(obj)
            i = [symphonyui.app.AcquisitionService.NONE_ID, obj.protocolDescriptorRepository.getAllIds()];
        end

        function selectProtocol(obj, id)
            obj.session.protocol = obj.getProtocol(id);
            obj.session.protocolId = id;
            obj.session.protocol.setRig(obj.getRig());
            notify(obj, 'SelectedProtocol');
        end

        function p = getProtocol(obj, id)
            if strcmp(id, symphonyui.app.AcquisitionService.NONE_ID)
                className = 'symphonyui.app.nulls.NullProtocol';
            else
                descriptor = obj.protocolDescriptorRepository.get(id);
                className = descriptor.class;
            end
            constructor = str2func(className);
            p = constructor();
        end

        function i = getCurrentProtocolId(obj)
            if isfield(obj.session, 'protocolId')
                i = obj.session.protocolId;
            else
                i = symphonyui.app.AcquisitionService.NONE_ID;
            end
        end

        function p = getCurrentProtocol(obj)
            if isfield(obj.session, 'protocol')
                p = obj.session.protocol;
            else
                p = obj.getProtocol(symphonyui.app.AcquisitionService.NONE_ID);
            end
        end

        %% Acquisition

        function record(obj)
            if ~obj.hasCurrentExperiment()
                error('No experiment open');
            end
            rig = obj.getRig();
            protocol = obj.getCurrentProtocol();
            experiment = obj.getCurrentExperiment();
            rig.record(protocol, experiment);
        end

        function preview(obj)
            rig = obj.getRig();
            protocol = obj.getCurrentProtocol();
            rig.preview(protocol);
        end

        function pause(obj)
            rig = obj.getRig();
            rig.pause();
        end

        function stop(obj)
            rig = obj.getRig();
            rig.stop();
        end

        function [tf, msg] = validate(obj)
            rig = obj.getRig();
            protocol = obj.getCurrentProtocol();
            [tf, msg] = rig.isValid();
            if tf
                [tf, msg] = protocol.isValid();
            end
        end

    end

end