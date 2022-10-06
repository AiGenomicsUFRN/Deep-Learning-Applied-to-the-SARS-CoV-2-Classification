function [seq]=mutation(seq, numberMut)
    gap=3;
    seq=char(seq);
    %%%%%criando os vetores referente à posição das mutação
    for i=1:size(seq,1)
        %%seq(i,:)=strtrim(seq(i,:));
        id=randperm(length(seq(i,:)),numberMut);
        divInt=floorDiv(length(id),2);
        half1=id(1:divInt);
        half2=id(divInt+1:end);
        %primeira etapa da mutação
        for n=1:length(half1)
           aux=seq(i,half1(n));
           if half1(n)+3 > length(seq(i,:))
               seq(i,half1(n))=seq(i,half1(n)-gap);
               seq(i,half1(n)-gap)=aux;
           else
               seq(i,half1(n))=seq(i,half1(n)+gap);
               seq(i,half1(n)+gap)=aux;
           end
        end
        %segunda etapa da mutação
        for k=1:size(seq,1)
            for j= 1:length(half2)
                if seq(k,half2(j))=="A"
                    seq(k,half2(j))="C";
                elseif seq(k,half2(j))=="C" 
                   seq(k,half2(j))="G";
                elseif seq(k,half2(j))=="T"
                    seq(k,half2(j))="A";
                elseif seq(k,half2(j))=="G"
                    seq(k,half2(j))="C"; 
                end      
            end

        end 
    end
end


