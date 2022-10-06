clear
if exist("temp.fasta")
    delete ("temp.fasta");
end
load('conjTest.mat')
rng(1234556778);
temp = [];
s=ls("..\Datasets\BlastBetaCoronavirusDB\Betacoronavirus.*.nsq");
s = extractBefore(string(s),'.nsq');

T=[];
nSeqBlast =5;
for j=1:17%18:size(conj_testes,1)
        data.Sequence = char(conj_testes.Sequence(j));
        data.Sequence=mutation(data.Sequence,9000);
        data.Header = char("Sequencia" + j);
        fastawrite("temp.fasta",data);
    disp(j)

    for i=1:size(s,1)

        tic
        [status1, resp1]=system("..\NCBI\blast-BLAST_VERSION+\bin\blastn -db ..\Datasets\BlastBetaCoronavirusDB\" + ...
            s(i) +  " -query " + "temp.fasta" + ...
            " -outfmt 6 -max_target_seqs " + nSeqBlast + " -max_hsps 1");
        tt =toc;
        temp=[temp;tt];
 

     if (status1 ~= 0)
            disp("Error: " + s(i) +  " Time: " + tt);
        else
            disp("Ok: " + s(i) +  " Time: " + tt);
     end
   
      R=split(string(resp1));
    R=R(1:end-1);

    if isempty(R)
        nSeqFind = 0;
    else
        R = reshape(R,12,size(R,1)/12)';
        R = array2table(R);
        R2 = [R(:,1:2) array2table(double(table2array(R(:,3:end))))];
        nSeqFind = size(R2,1);
        R2.Base = i*ones(nSeqFind,1);
        T = [T;R2];
%         if size(R2,1) == nSeqFind
%             break
%         end
    end
        disp(nSeqFind)
    end    
           clear data;
      delete ("temp.fasta");
% % % %     save(string("BD_"+i+".mat"),T)
end

quant=unique(T.R1);
acertos=size(quant,1)/size(conj_testes,1)