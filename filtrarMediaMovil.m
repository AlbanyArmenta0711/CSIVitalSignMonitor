function [ filteredSignal ] = filtrarMediaMovil(noiseSignal,window)
    %La ventana debe ser menor al numero de elementos de la señal
    if window<numel(noiseSignal)
    filteredSignal = zeros(numel(noiseSignal),1);
        for i=1:numel(noiseSignal)
            %Para los primeros elementos, sin poder tomar la ventana completa
            if i <= (floor(window/2)) 
                elementosContados = 0; 
                %Se suman los superiores, contando el actual 
                for j=i:ceil(window/2)
                    filteredSignal(i)= filteredSignal(i)+noiseSignal(j);
                    elementosContados = elementosContados +1;
                end
                %Se suman los inferiores
                k=i-1;
                while k>0
                    elementosContados = elementosContados +1;
                    filteredSignal(i) = filteredSignal(i)+noiseSignal(k);
                    k=k-1;
                end 
                filteredSignal(i) = filteredSignal(i)/elementosContados;
            else
              %En caso de ser los ultimos elementos y que no alcance a
              %tomar la ventana completa
              elementosContados = 0;
              if i > (numel(noiseSignal)-ceil(window/2))
                  %Se suman los inferiores, con i inclusivo
                  for j=i-floor(window/2):i
                      elementosContados = elementosContados+1;
                      filteredSignal(i) = filteredSignal(i)+noiseSignal(j);
                  end
                  %Se suman los superiores
                  k=i+1;
                  while k <= numel(noiseSignal)
                      elementosContados = elementosContados+1;
                      filteredSignal(i) = filteredSignal(i)+noiseSignal(k);
                      k=k+1;
                  end
                  filteredSignal(i) = filteredSignal(i)/elementosContados;
              else
                  %Se suman los inferores, incluyendo i
                  for j=i-floor(window/2):i
                      filteredSignal(i) = filteredSignal(i)+noiseSignal(j);
                  end 
                  %Se suman los superiores
                  for k=i+1:i+ceil(window/2)-1
                      filteredSignal(i) = filteredSignal(i)+noiseSignal(k);
                  end
                  filteredSignal(i) = filteredSignal(i)/window;
              end
            end 
        end
    end
end

