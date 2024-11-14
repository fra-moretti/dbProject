								-- Data Analytics 2, Ottimizzazione dei Consumi Energetici --

/* L'idea di base è quella di effettuare una previsione della produzione energetica facendo la media
basata sulla produzione degli ultimi 10 giorni, poi in base a quella appena un utente utilizza 
un programma gli viene mostrato un avviso riguardante il consumo fatto con esso. */

-- Innanzitutto bisogna creare un event che ogni giorno calcola la media della produzione energetica
-- negli ultimi 10 giorni, come se fosse una previsione di quello che verrà prodotto quel giorno


drop event if exists energia_prodotta;
delimiter $$
create event energia_prodotta 
on schedule every 1 day
starts current_date + interval 1 day at '00:00:00'
do 
			
			select avg(D.Livello)
			from (
					select sum(P.Livello) as Livello							-- per ogni giorno si calcola la somma del livello di
					from Produzione P											-- energia prodotta
					where date(P.Timestamp) + interval 10 day > current_date
					group by day(P.Timestamp)
			) as D
			into @energia_prevista;												-- calcoliamo media energia prodotta come q
			
delimiter ;


-- adesso bisogna capire quanto consuma un determinato dispositivo settato con un programma
-- la cosa che si fa è calcolare il consumo totale dei dispositivi a programma e quante ore 
-- è stato utilizzato, per calcolarci il consumo orario dei dispositivi


				drop table if exists consumo_orario;
							
				create table consumo_orario as (
							select D.CodDispositivo, (D.ConsumoTotale/D.OreTotali) as ConsumoOrario
							from (
									select I.CodDispositivo, sum(P.Livello) as ConsumoTotale, sum(datediff(I.Fine, I.Inizio)) as OreTotali
									from Interazione I inner join Programma P on I.CodDispositivo = P.Dispositivo
									group by I.CodDispositivo
								) as D
				);

-- Trigger per la creazione del suggerimento 

drop trigger if exists Ricevi_Suggerimento;
delimiter $$
create trigger Ricevi_Suggerimento
before insert on Interazione
for each row
begin	

		declare dieci_per_cento double default 0;
        
		if exists (											-- se si tratta di un'interazione con dispositivo a programma
					select *
                    from Programma
					where NEW.CodDispositivo = Dispositivo
        ) then 	
				
                -- vogliamo che il dispositivo consumi massimo il 10% dell'energia prodotta in quel giorno
                -- quindi bisogna calcolarci a quanto ammonta tale energia e in quanti minuti si otterrebbe
                -- tale energia
                

				set dieci_per_cento = @energia_prevista * 0.01;
                set @ore = 0;
                set consumo_orario = (
										select ConsumoOrario
                                        from consumo_orario
                                        where CodDispositivo = NEW.CodDispositivo
									);
                
                label: loop
						set dieci_per_cento = dieci_per_cento - consumo_orario;
                        
                        if (dieci_per_cento < 0) then 
							leave label;
						end if;
                        
                        set @ore = @ore + 1;
                        
				end loop;
                
                if @ore > 0 then 
                
					set @advice = concat("Si consiglia l'utilizzo del Dispositivo ", NEW.CodDispositivo, 
                    " per ", @ore*60 ,"minuti");
					select @advice;
                
                else 
					
                    set @advice = concat("Si sconsiglia l'utilizzo del Dispositivo ", NEW.CodDispositivo); 
                    select @advice;

                end if;
                
        end if;


end $$
delimiter ;

-- il trigger precedente va eseguito 

-- trigger per 

drop trigger if exists Aggiorna_Suggerimento;
delimiter $$
create trigger Aggiorna_Suggerimento
after insert on Interazione
for each row
begin	
		
        declare programma varchar(20) default '';
        
		if exists (											-- se si tratta di un'interazione con dispositivo a programma
					select *
                    from Programma
					where NEW.CodDispositivo = Dispositivo
        ) then
			
				select P.CodProgramma
				from Programmazione P
				where NEW.CodDispositivo = P.CodDispositivo
                into programma;
                
				if datediff(Fine, Inizio) >= @ore then 		-- se il suggerimento è stato ascoltato
						
                        insert into Suggerimento values (null, NEW.Inizio, NEW.Account, programma, 1);	-- si setta a 1 SceltaUtente
                        
				else										-- suggerimento non seguito
						
                        insert into Suggerimento values (null, NEW.Inizio, NEW.Account, programma, 0);	-- si setta a 0 SceltaUtente
                        
                end if;
        
        end if;
				

end $$
delimiter ;