function ui = mrViewMeshPanel(ui, dockFlag, vis);
%
% ui = mrViewMeshPanel(ui, [dockFlag], [vis=0]);
%
% Adds a panel to the mrViewer UI with
% controls for displaying data onto 3D meshes.
%
% dockFlag: if 1,  will attach panel to the 
% mrViewer figure. Otherwise,  will make a 
% separate figure for the panel.
%
% vis: if 0, will initialize the panel to be hidden (default when
% starting up mrViewer); otherwise, leave it visible (as when 
% docking/undocking the panel).
%
% ras,  07/13/06.
if ~exist('ui','var') | isempty(ui),   ui = mrViewGet; end
if ~exist('dockFlag','var') | isempty(dockFlag),   dockFlag = 1; end
if ~exist('vis','var') | isempty(vis),   vis = 0; end

mrGlobals2;

bgColor = [.9 .9 .9];

if dockFlag==1
    ui.panels.mesh = mrvPanel('right',   0.2,  ui.fig,  'normalized');
else
    hfig = figure('Name',   sprintf('Info [%s]', ui.tag),   ...
                  'Units',   'normalized',   ...
                  'Position',  [.88 .5 .12 .5],   ...
                  'MenuBar',   'none',   ...
                  'NumberTitle',   'off',   ...
                  'UserData', ui.tag);              
    ui.panels.mesh = uipanel('Parent', hfig, 'Units',   'normalized',   ...
                               'Position',  [0 0 1 1]);
	% close request function for this figure: just toggle visibility
    crf = 'tmp = findobj(''Parent'', gcf, ''Type'', ''uipanel''); ';
    crf = [crf 'mrvPanelToggle(tmp); clear tmp;'];
    set(hfig, 'CloseRequestFcn', crf);
end

set(ui.panels.mesh, 'BackgroundColor', bgColor, 'Title', 'Mesh', ...
    'ShadowColor', bgColor, 'UIContextMenu', meshPanelContextMenu(ui));

% add a popup showing the selected segmentation
uicontrol('Parent', ui.panels.mesh, 'Style', 'text', 'String', 'Selected Segmentation', ...
    'Units', 'normalized', 'Position', [.1 .95 .8 .03], ...
    'HorizontalAlignment', 'left', 'BackgroundColor', [.9 .9 .9]);   

ui.controls.segSelect = uicontrol('Parent', ui.panels.mesh, 'Style', 'popup',...
	'String', {'(none loaded)'}, 'Value', 1, ...
    'Units', 'normalized', 'Position', [.1 .91 .8 .04], ...
    'HorizontalAlignment', 'left', 'BackgroundColor', [1 1 1], ...
	'Callback', 'mrViewSet(gcf, ''SegmentationNum'', get(gcbo, ''Value''));');   


% add a popup menu showing all meshes loaded (across all segmentations)
uicontrol('Parent', ui.panels.mesh, 'Style', 'text', 'String', 'Selected Mesh', ...
    'Units', 'normalized', 'Position', [.1 .86 .8 .03], ...
    'HorizontalAlignment', 'left', 'BackgroundColor', [.9 .9 .9]);   

ui.controls.meshSelect = uicontrol('Parent', ui.panels.mesh, 'Style', 'popup',...
	'String', {'(none loaded)'}, 'Value', 1, ...
    'Units', 'normalized', 'Position', [.1 .82 .8 .04], ...
    'HorizontalAlignment', 'left', 'BackgroundColor', [1 1 1], ...
	'Callback', 'mrViewSelectMesh(gcf, get(gcbo, ''Value''));');   

% update all meshes button
ui.controls.meshUpdateAll = uicontrol('Parent', ui.panels.mesh,  ...
    'Style', 'pushbutton',  'String', 'Update All', ...
    'BackgroundColor', [.9 .8 .9], ...
    'Units', 'normalized', 'Position', [.1 .78 .8 .04],   ...
    'Callback', 'mrViewUpdateAllMeshes; ');

         
% mesh update button
ui.controls.meshUpdate = uicontrol('Parent', ui.panels.mesh,  ...
    'Style', 'pushbutton',  'String', 'Update', ...
    'BackgroundColor', [.9 .8 .8], ...
    'Units', 'normalized', 'Position', [.1 .7 .8 .04],   ...
    'Callback', 'mrViewMesh; ');

% mesh open button
cb = 'mrViewLoad(gcf, [], ''Mesh''); mrViewDisplayMesh; ';
ui.controls.meshUpdate = uicontrol('Parent', ui.panels.mesh,  ...
    'Style', 'pushbutton',  'String', 'Open', ...
    'BackgroundColor', [.9 .8 .8], ...
    'Units', 'normalized', 'Position', [.1 .65 .4 .04],   ...
    'Callback', cb);

% mesh close button
cb = ['segCloseMesh( mrViewGet(gcf, ''Segmentation'') );'];
ui.controls.meshUpdate = uicontrol('Parent', ui.panels.mesh,  ...
    'Style', 'pushbutton',  'String', 'Close', ...
    'BackgroundColor', [.9 .8 .8], ...
    'Units', 'normalized', 'Position', [.5 .65 .4 .04],   ...
    'Callback', cb);
   
% mesh get ROI button
cb = ['mrViewROI(''mesh''); '];
ui.controls.meshUpdate = uicontrol('Parent', ui.panels.mesh,  ...
    'Style', 'pushbutton',  'String', 'Get ROI', ...
    'BackgroundColor', [.9 .8 .8], ...
    'Units', 'normalized', 'Position', [.1 .6 .4 .04],   ...
    'Callback', cb);
        
    
% mesh get Disk button (N.Y.I.; just does mesh ROI layer 1 xform now)
cb = ['mrViewROI(''meshgrow''); '];
ui.controls.meshUpdate = uicontrol('Parent', ui.panels.mesh,  ...
    'Style', 'pushbutton',  'String', 'Grow ROI', ...
    'BackgroundColor', [.9 .8 .8], ...
    'Units', 'normalized', 'Position', [.5 .6 .4 .04],   ...
    'Callback', cb);
    

% toggle cursor button
ui.controls.meshUpdate = uicontrol('Parent', ui.panels.mesh,  ...
    'Style', 'pushbutton',  'String', 'Cursor', ...
    'BackgroundColor', [.9 .8 .8], ...
    'Units', 'normalized', 'Position', [.1 .55 .4 .04],   ...
    'Callback', 'meshToggleCursor(mrViewGet(gcf, ''mesh''));'); % 'mrViewSetCursorFromMesh;'
        
    
% mesh prefs button
ui.controls.meshUpdate = uicontrol('Parent', ui.panels.mesh,  ...
    'Style', 'pushbutton',  'String', 'Prefs', ...
    'BackgroundColor', [.9 .8 .8], ...
    'Units', 'normalized', 'Position', [.5 .55 .4 .04],   ...
    'Callback', 'mrmPreferences; ');
    
    
%%%%%%%%%%%%%%%%%%%
%% Mesh Settings %%
%%%%%%%%%%%%%%%%%%%
% listbox w/ settings
mrGlobals2;
names = {''};
uicontrol('Parent', ui.panels.mesh, 'Style', 'text', 'String', 'Settings', ...
    'Units', 'normalized', 'Position', [.1 .45 .8 .05], 'FontSize', 12, ...
    'HorizontalAlignment', 'left', 'BackgroundColor', [.9 .9 .9]);   
    
h.settingsList = uicontrol('Parent', ui.panels.mesh, 'Style', 'listbox', ...
                   'Units', 'normalized', 'Position', [.1 .2 .8 .25], ...
                   'String', names, 'Tag', 'MeshSettingsList');               
               
% store settings button
callback = 'meshStoreSettings(mrViewGet(gcf, ''CurMesh'')); ';
h.store = uicontrol('Parent', ui.panels.mesh, 'Style', 'pushbutton', ...
            'Units', 'normalized', 'Position', [.1 .15 .4 .04], ...
            'String', 'Store', 'Callback', callback);

% retrieve settings button
callback = 'meshRetrieveSettings(mrViewGet(gcf, ''CurMesh'')); ';
h.retrieve = uicontrol('Parent', ui.panels.mesh, 'Style', 'pushbutton', ...
            'Units', 'normalized', 'Position', [.1 .1 .4 .04], ...
            'String', 'Retrieve', 'Callback', callback);
        
% rename settings button
callback = 'meshRenameSettings(mrViewGet(gcf, ''CurMesh'')); ';
h.rename = uicontrol('Parent', ui.panels.mesh, 'Style', 'pushbutton', ...
            'Units', 'normalized', 'Position', [.5 .15 .4 .04], ...
            'String', 'Rename', 'Callback', callback);

% delete settings button
callback = 'meshDeleteSettings(mrViewGet(gcf, ''CurMesh'')); ';
h.delete = uicontrol('Parent', ui.panels.mesh, 'Style', 'pushbutton', ...
            'Units', 'normalized', 'Position', [.5 .1 .4 .04], ...
            'String', 'Delete', 'Callback', callback);
        
% % manual zoom slider
% cb = ['MSH = mrViewGet(gcf, ''SelectedMesh''); ' ...
%       'TMP = mrmGet(MSH,''Camera''); TMP.actor = 0; ' ...
%       'TMP.frustum(2) = 600 - get(gcbo, ''Value''); ' ...
%       'mrMesh(MSH.host, MSH.id, ''set'', TMP); clear TMP MSH;'];
% h.zoom = uicontrol('Parent', ui.panels.mesh, 'Style', 'slider', ...
%             'Min', 0, 'Max', 600, ...
%             'Units', 'normalized', 'Position', [.1 .05 .8 .04], ...
%             'String', 'Zoom', 'Callback', cb);
% uicontrol('Parent', ui.panels.mesh, 'Style', 'text', 'Units', 'normalized', ...
%     'Position', [.1 .1 .8 .04], 'String', 'Manual Zoom', ...
%     'HorizontalAlignment', 'left');    

ui.meshHandles = h;

%%%%%hide the panel if requested
if vis==0
	mrvPanelToggle(ui.panels.mesh, 'off');    
end

return




function h = meshPanelContextMenu(ui);
% creates a UI Context menu for the mesh panel. This initially has a single
% option, allowing you to set the mesh width (in case it gets screwed up).
% In the future, I may add more context-specific operations.
h = uicontextmenu;

cb = ['UI = mrViewGet;  TMP_POS = get(UI.panels.mesh, ''Position''); ' ...
	  'PROMPT = {''Enter New Panel Width: ''}; ' ...
	  'DEF = {num2str(TMP_POS(3))}; ' ...
	  'TMP_RESP = inputdlg(PROMPT, ''Mesh Panel'', 1, DEF); ' ...
	  'TMP_POS(3) = str2num( TMP_RESP{1} ); ' ...
	  'set(ui.panels.mesh, ''Position'', TMP_POS); ' ...
	  'clear UI TMP_POS PROMPT DEF TMP_RESP TMP_POS; '];
uimenu(h, 'Label', 'Set Panel Width');

return

	  
