%% t_meshOBJ
%
% Create a mesh object from a vistasoft mesh
%
% See t_meshCreate for a little more on creating meshes
%

%% Make sure vistadata is on your path

dataD = mrvDataRootPath;
fName = fullfile(dataD,'anatomy','anatomyNIFTI','t1_class.nii.gz');

% Run the build code
msh = meshBuildFromClass(fName,[],'left');
msh = meshSmooth(msh);
% msh = meshColor(msh);

% Visualize the coarse, unshaded mesh
meshVisualize(msh);

%% Put the mesh data into the format Matlab uses

% THIS DOES NOT WORK YET, AND I HAVE NOT STARTED REALLY DEBUGGING

% Center around (0,0)
vMean = mean(msh.vertices');
FV.vertices = bsxfun(@minus,msh.vertices',vMean);

FV.faces    = msh.triangles';

% Calculate Iso-Normals of the surface
N = isonormals(Ds,FV.vertices);
L = sqrt(N(:,1).^2+N(:,2).^2+N(:,3).^2)+eps;
N(:,1)= N(:,1)./L; N(:,2)=N(:,2)./L; N(:,3)=N(:,3)./L;

FV.faces=[FV.faces(:,3) FV.faces(:,2) FV.faces(:,1)];

%% Make a material structure
material(1).type='newmtl';
material(1).data='skin';
material(2).type='Ka';
material(2).data=[0.8 0.4 0.4];
material(3).type='Kd';
material(3).data=[0.8 0.4 0.4];
material(4).type='Ks';
material(4).data=[1 1 1];
material(5).type='illum';
material(5).data=2;
material(6).type='Ns';
material(6).data=27;

% Make OBJ structure
clear OBJ
OBJ.vertices = FV.vertices;
OBJ.vertices_normal = N;
OBJ.material = material;
OBJ.objects(1).type='g';
OBJ.objects(1).data='skin';
OBJ.objects(2).type='usemtl';
OBJ.objects(2).data='skin';
OBJ.objects(3).type='f';
OBJ.objects(3).data.vertices=FV.faces;
OBJ.objects(3).data.normal=FV.faces;

fname = fullfile(mrvDataRootPath,'cortex.obj');
objWrite(OBJ,fname);
fprintf('Wrote out OBJ file:  %s\n',fname);

%% END
