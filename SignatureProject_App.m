classdef SignatureProject_App < matlab.apps.AppBase

    properties (Access = public)
        figure1 matlab.ui.Figure
        panel matlab.ui.container.Panel
        panel2 matlab.ui.container.Panel

        axes1 matlab.ui.control.UIAxes
        axes2 matlab.ui.control.UIAxes
        axes3 matlab.ui.control.UIAxes
        axes4 matlab.ui.control.UIAxes

        axes5 matlab.ui.control.UIAxes
        axes6 matlab.ui.control.UIAxes
        axes7 matlab.ui.control.UIAxes
        axes8 matlab.ui.control.UIAxes
        axes9 matlab.ui.control.UIAxes
        axes10 matlab.ui.control.UIAxes

        pushbutton1 matlab.ui.control.Button
        pushbutton2 matlab.ui.control.Button
        pushbutton3 matlab.ui.control.Button
        pushbutton4 matlab.ui.control.Button
        pushbutton5 matlab.ui.control.Button
        pushbutton10 matlab.ui.control.Button
        pushbutton11 matlab.ui.control.Button

        resultview matlab.ui.control.Label
    end

    properties (Access = private)
        img1
        img2
        img3
        img4
    end

    methods (Access = private)

        %% SELECT ORIGINAL
        function pushbutton1_Callback(app, ~)
            [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff','Image Files'});
            if isequal(file,0), return; end
            app.img1 = imread(fullfile(path,file));
            imshow(app.img1,'Parent',app.axes1);
            imshow(app.img1,'Parent',app.axes7);
        end

        %% SELECT SAMPLE 1
        function pushbutton2_Callback(app, ~)
            [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff','Image Files'});
            if isequal(file,0), return; end
            app.img2 = imread(fullfile(path,file));
            imshow(app.img2,'Parent',app.axes2);
            imshow(app.img2,'Parent',app.axes8);
        end

        %% SELECT SAMPLE 2
        function pushbutton4_Callback(app, ~)
            [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff','Image Files'});
            if isequal(file,0), return; end
            app.img3 = imread(fullfile(path,file));
            imshow(app.img3,'Parent',app.axes3);
            imshow(app.img3,'Parent',app.axes9);
        end

        %% SELECT SAMPLE 3
        function pushbutton5_Callback(app, ~)
            [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff','Image Files'});
            if isequal(file,0), return; end
            app.img4 = imread(fullfile(path,file));
            imshow(app.img4,'Parent',app.axes4);
            imshow(app.img4,'Parent',app.axes10);
        end

        %% CLEAR
        function pushbutton11_Callback(app, ~)
            cla(app.axes1); cla(app.axes2); cla(app.axes3); cla(app.axes4);
            cla(app.axes5); cla(app.axes6);
            cla(app.axes7); cla(app.axes8); cla(app.axes9); cla(app.axes10);

            app.resultview.Text = '';
        end

        %% RESULT (MULTI-COMPARISON)
        function pushbutton3_Callback(app, ~)

            if isempty(app.img1) || isempty(app.img2) || ...
               isempty(app.img3) || isempty(app.img4)

                uialert(app.figure1,'Please select all 4 images','Error');
                return;
            end

            % Feature Extraction
            [V1,p1] = SignatureProjectFuntion(app.img1);
            [V2,p2] = SignatureProjectFuntion(app.img2);
            [V3,~] = SignatureProjectFuntion(app.img3);
            [V4,~] = SignatureProjectFuntion(app.img4);

            % Show processed
            imshow(p1,'Parent',app.axes5);
            imshow(p2,'Parent',app.axes6);

            % Distance (Euclidean)
            d2 = norm(V1 - V2);
            d3 = norm(V1 - V3);
            d4 = norm(V1 - V4);

            distances = [d2 d3 d4];

            % Best Match
            [minVal, idx] = min(distances);

            % Ranking
            [sortedVals, sortedIdx] = sort(distances);

            % Result text
            resultText = sprintf(['Closest Match: Signature %d\n' ...
                'Distance: %.4f\n\nRanking:\n1st: Sig %d\n2nd: Sig %d\n3rd: Sig %d'], ...
                idx+1, minVal, ...
                sortedIdx(1)+1, sortedIdx(2)+1, sortedIdx(3)+1);

            app.resultview.Text = resultText;

            uialert(app.figure1,resultText,'Result');
        end

    end

    %% UI SETUP
    methods (Access = private)

        function createComponents(app)

            app.figure1 = uifigure('Position',[100 100 1200 600],'Name','Signature Verification');

            app.panel = uipanel(app.figure1,'Position',[20 20 550 550]);
            app.panel2 = uipanel(app.figure1,'Position',[600 20 580 550]);

            % AXES INPUT
            app.axes1 = uiaxes(app.panel,'Position',[20 350 200 150]);
            app.axes2 = uiaxes(app.panel,'Position',[300 350 200 150]);
            app.axes3 = uiaxes(app.panel,'Position',[20 150 200 150]);
            app.axes4 = uiaxes(app.panel,'Position',[300 150 200 150]);

            % AXES OUTPUT
            app.axes5 = uiaxes(app.panel2,'Position',[50 350 200 150]);
            app.axes6 = uiaxes(app.panel2,'Position',[300 350 200 150]);

            app.axes7 = uiaxes(app.panel2,'Position',[50 150 150 120]);
            app.axes8 = uiaxes(app.panel2,'Position',[220 150 150 120]);
            app.axes9 = uiaxes(app.panel2,'Position',[390 150 150 120]);
            app.axes10 = uiaxes(app.panel2,'Position',[200 20 150 120]);

            % BUTTONS
            app.pushbutton1 = uibutton(app.panel,'Text','Original',...
                'Position',[50 310 150 30],'ButtonPushedFcn',@(s,e)pushbutton1_Callback(app));

            app.pushbutton2 = uibutton(app.panel,'Text','Sample 1',...
                'Position',[320 310 150 30],'ButtonPushedFcn',@(s,e)pushbutton2_Callback(app));

            app.pushbutton4 = uibutton(app.panel,'Text','Sample 2',...
                'Position',[50 110 150 30],'ButtonPushedFcn',@(s,e)pushbutton4_Callback(app));

            app.pushbutton5 = uibutton(app.panel,'Text','Sample 3',...
                'Position',[320 110 150 30],'ButtonPushedFcn',@(s,e)pushbutton5_Callback(app));

            app.pushbutton3 = uibutton(app.panel,'Text','COMPARE',...
                'Position',[200 10 150 40],'ButtonPushedFcn',@(s,e)pushbutton3_Callback(app));

            app.pushbutton11 = uibutton(app.panel,'Text','CLEAR',...
                'Position',[50 10 120 40],'ButtonPushedFcn',@(s,e)pushbutton11_Callback(app));

            % RESULT LABEL
            app.resultview = uilabel(app.panel2,...
                'Position',[50 300 450 40],'FontSize',14);
        end
    end

    methods (Access = public)

        function app = SignatureProject_App
            createComponents(app)
        end
    end
end
