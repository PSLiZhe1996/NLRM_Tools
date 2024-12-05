function COMSOLMesh(comsolfilename,elefilename,nodefilename)
comsolfile=fopen(comsolfilename,'r');
index=0;
zone_index=0;
zone_flag='B8';%W6 P5 B7 T4

while ~feof(comsolfile)
    sline=fgetl(comsolfile);
    index=index+1;
    if isempty(sline)
        continue
    end
    target=find(sline=='#');
    if ~isempty(target)
        switch sline(target(1):end)
            case '# number of mesh vertices'
                num_vertices=str2double(sline(1:target(1)-1));
                disp(['number of gridpoints: ',num2str(num_vertices)]);
                continue;
            case '# Mesh vertex coordinates'
                fid=fopen('Grid.tmp','w');
                for i=1:num_vertices
                    node=str2num(fgetl(comsolfile));
                    fprintf(fid,'%d\t%.15e\t%.15e\t%.15e\n',i,node);
                    index=index+1;
                end
                fclose(fid);
                disp('Grid.tmp');
            case '# number of element types'
                disp(['number of element types: ',sline(1:target(1)-1)]);
                disp('Zones.tmp');
                fid=fopen('Zone.tmp','w');
                zones=cell(str2double(sline(1:target(1)-1)),2);
                while true
                    sline=fgetl(comsolfile);
                    index=index+1;
                    while isempty(sline)
                        sline=fgetl(comsolfile);
                        index=index+1;
                    end
                    target=find(sline=='#');
                    switch length(target)
                        case 0
                            switch ReadMode
                                case '# Elements'
                                    switch zone_type
                                        case '5 prism '
                                            zone_flag='W6';
                                            disp([zone_flag,' zones, number: ',num2str(number_of_elements)]);
                                            for i=1:number_of_elements-1
                                                zone_index=zone_index+1;
                                                node=str2num(sline);
                                                fprintf(fid,'%d ',zone_index);
                                                fprintf(fid,'%d ',node([1 2 3 3 4 5 6 6])+1);
                                                fprintf(fid,'\n');
                                                sline=fgetl(comsolfile);
                                                index=index+1;
                                            end
                                            zone_index=zone_index+1;
                                            node=str2num(sline);
                                            fprintf(fid,'%d ',zone_index);
                                            fprintf(fid,'%d ',node([1 2 3 3 4 5 6 6])+1);
                                            fprintf(fid,'\n');
                                        case '3 hex '
                                            zone_flag='B8';
                                            disp([zone_flag,' zones, number: ',num2str(number_of_elements)]);
                                            for i=1:number_of_elements-1
                                                zone_index=zone_index+1;
                                                node=str2num(sline);
                                                fprintf(fid,'%d ',zone_index);
                                                fprintf(fid,'%d ',node([1 2 3 4 5 6 7 8])+1);
                                                fprintf(fid,'\n');
                                                sline=fgetl(comsolfile);
                                                index=index+1;
                                            end
                                            zone_index=zone_index+1;
                                            node=str2num(sline);
                                            fprintf(fid,'%d ',zone_index);
                                            fprintf(fid,'%d ',node([1 2 3 4 5 6 7 8])+1);
                                            fprintf(fid,'\n');
                                        case '3 tet '
                                            zone_flag='T4';
                                            disp([zone_flag,' zones, number: ',num2str(number_of_elements)]);
                                            for i=1:number_of_elements-1
                                                zone_index=zone_index+1;
                                                node=str2num(sline);
                                                fprintf(fid,'%d ',zone_index);
                                                fprintf(fid,'%d ',node([1 2 3 3 4 4 4 4])+1);
                                                fprintf(fid,'\n');
                                                sline=fgetl(comsolfile);
                                                index=index+1;
                                            end
                                            zone_index=zone_index+1;
                                            node=str2num(sline);
                                            fprintf(fid,'%d ',zone_index);
                                            fprintf(fid,'%d ',node([1 2 3 3 4 4 4 4])+1);
                                            fprintf(fid,'\n');
                                        case '3 pyr '
                                            zone_flag='P5';
                                            disp([zone_flag,' zones, number: ',num2str(number_of_elements)]);
                                            array=[1 2 3 4 5 5 5 5];
                                            for i=1:number_of_elements-1
                                                zone_index=zone_index+1;
                                                node=str2num(sline);
                                                fprintf(fid,'%d ',zone_index);
                                                fprintf(fid,'%d ',node(array)+1);
                                                fprintf(fid,'\n');
                                                sline=fgetl(comsolfile);
                                                index=index+1;
                                            end
                                            zone_index=zone_index+1;
                                            node=str2num(sline);
                                            fprintf(fid,'%d ',zone_index);
                                            fprintf(fid,'%d ',node(array)+1);
                                            fprintf(fid,'\n');
                                        otherwise
                                            disp('Error!!!');
                                            pause;
                                    end
                                    
                                case '# Geometric entity indices'
                                    disp('Store zone indices');
                                    for i=1:number_of_geometric_entity_indices-1
                                        zones{zone_type_index,2}(i)=str2double(sline);
                                        sline=fgetl(comsolfile);
                                        index=index+1;
                                    end
                                    zones{zone_type_index,2}(number_of_geometric_entity_indices)=str2double(sline);
                            end
                        case 1
                            switch sline(target(1):end)
                                case '# type name'
                                    zone_type=sline(1:target(1)-1);
                                case '# number of vertices per element'
                                    number_of_vertices_per_element=str2double(sline(1:target(1)-1));
                                case '# number of elements'
                                    number_of_elements=str2double(sline(1:target(1)-1));
                                case '# Elements'
                                    ReadMode='# Elements';
                                case '# number of geometric entity indices'
                                    number_of_geometric_entity_indices=str2double(sline(1:target(1)-1));
                                    zones{zone_type_index,1}=number_of_geometric_entity_indices;
                                    zones{zone_type_index,2}=zeros(1,number_of_geometric_entity_indices);
                                case '# Geometric entity indices'
                                    ReadMode='# Geometric entity indices';
                            end
                        case 2
                            zone_type_index=str2double(sline(target(2)+1:end))+1;
                    end
                    if feof(comsolfile)
                        break;
                    end
                end
                fclose(fid);
        end
    end
end
fclose(comsolfile);

elefile=fopen(elefilename,'w');
nodefile=fopen(nodefilename,'w');

gridfile=fopen('Grid.tmp','r');
zonefile=fopen('Zone.tmp','r');
disp('Write grid data...');
fprintf(nodefile,"%d\n",num_vertices);

while ~feof(gridfile)
    data=fgetl(gridfile);
    data=str2num(data);
    fprintf(nodefile,'%f ',data(2:end));
    fprintf(nodefile,'\n');
end
fclose(gridfile);
fclose(nodefile);
delete Grid.tmp

zone_flag=0;
number_of_zones=0;
for i=1:size(zones,1)
    number_of_zones=number_of_zones+zones{i,1};
end
zone_lable=zeros(2,number_of_zones);
zone_lable(1,:)=1:number_of_zones;
for i=1:size(zones,1)
    zone_indices=(1:zones{i,1})+zone_flag;
    zone_flag=zone_indices(end);
    zone_lable(2,zone_indices)=zones{i,2};
end
max_lable=max(zone_lable(2,:));


disp('Write zone data...');
fprintf(elefile,"%d\n",number_of_zones);
id=0;
while ~feof(zonefile)
    id=id+1;
    data=fgetl(zonefile);
    data=str2num(data);
    fprintf(elefile,"%d ",[data(2:end) zone_lable(2,id)]);
    fprintf(elefile,"\n");
end
fclose(zonefile);
fclose(elefile);
delete Zone.tmp

disp('All done!');
