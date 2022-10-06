function [M] = OneHotEncoding3D(Seq,MapSeq)

%MapSeq = 'ACGTN';

M = zeros(length(Seq),1,length(MapSeq));

for i=1:length(MapSeq)
    M(:,1,i) = Seq == MapSeq(i);
end
