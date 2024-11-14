
									--  Data Analytics 1, Association Rules Learning --


set @@group_concat_max_len=10000;
use mySmartHome;



										-- ------------------------------------ --
										-- 	   CREAZIONE TABELLE PRINCIPALI		--
										-- ------------------------------------ -- 

-- Creiamo la tabella delle transazioni avente come colonne l'identificatore delle transazioni: ottenuto con una variabile auto_increment, 
-- (tale variabile si incrementa automaticamente di 1 ad ogni inserimento di una transazione) e i dispositivi utilizzati in un determinato
-- giorno

	drop table if exists Transactions;
	create table Transactions (
		ID integer auto_increment,											-- identificazione transazione
		Dispositivi varchar(10000),											-- dispositivi utilizzati 
		primary key (ID)
	);
	with Transactions as (													-- inserimento dispositivi utilizzati in un determinato giorno
		select group_concat(distinct D.Nome) as Dispositivi					
		from Interazione I natural join Dispositivo D						-- scegliamo di prendere i nomi per una maggiore leggibilità
		group by I.Account, I.Inizio										-- utilizzati da un certo utente registrato in un determinato giorno, 
																			
	)
		select group_concat(concat('(NULL,''', T.Dispositivi, ''')') ) 		-- primo attributo NULL per l'auto_increment
		from Transactions T
		into @values;
	set @values =  concat('INSERT INTO Transactions values ', @values);		-- costruzione dell'insert completata
	prepare sql_statement from @values;
	execute sql_statement;													-- esecuzione dell'insert, la tabella Transazioni è stata popolata

drop function if exists calcolo_k;											-- calcoliamoci k, che è uguale al numero delle virgole + 1.
delimiter $$
create function calcolo_k()
returns integer not deterministic
begin 	
		declare elenco varchar(1000);
        declare k integer default 0;
        declare j integer; 							-- variabile di supporto
		declare scorri_transazioni cursor for(
			select *
            from Transactions
        );
        declare continue handler for not found set @finito = 1;
        
        open scorri_transazioni;
        
        label: loop
						fetch scorri_transazioni into elenco;
                        if @finito = 1 then 
							leave label;
						end if;
                        
						set j = length(elenco) + 1 - length(replace(elenco, ',', ''));	-- togliamo le virgole e guardiamo la differenza di lunghezza
							
						if k < j then 
							set k = j;
						end if;
        end loop label;
        
        close scorri_transazioni;
        
        return k;
	
end $$
delimiter ;


-- Ora bisogna rovesciare questa tabella, in modo tale da avere come colonne i dispositivi e come righe le transazioni, 
-- per ogni transazione bisogna sapere quante volte è presente un dispositivo 

select group_concat(concat(Nome, 'varchar(20) default ''')) 					-- ci si trova i dispositivi contenuti nella tabella
from Dispositivo into @create_pivot_transaction;

set @create_pivot_transaction = 
concat(	
		'create table Pivot_Transazioni(',
		'ID integer auto_increment, ', 											-- anche in questo caso si ha un identificatore per le transazioni
		@create_pivot_transaction, 
		',primary key(ID));'
        );
                          
drop table if exists Pivot_Transazioni;
prepare sql_statement from @create_pivot_transaction;
execute sql_statement;

-- In questo modo abbiamo creato una tabella avente come righe le transazioni e come colonne i dispositivi
-- La cosa da fare ora è il POPOLAMENTO di tale tabella, in modo tale che si setti il valore di una transazione nel momento in cui
-- si va ad utilizzare il dispositivo


	select group_concat(concat('sum(if(Nome= ''',Nome,''',1,0)) as ''', Nome, '''' ))	-- in questa parte si costruisce la select, si 	
	from Dispositivo																	-- somma 1 ogni volta che si trova un'interazione
	into @insert_pivot; 																-- con quel dispositivo
	
	set @insert_pivot = concat(
	'select',																			-- completiamo il codice
	@insert_pivot,
	' from Interazione I natural join Dispositivo D 
	group by I.Account, I.Inizio'  
	);
	
	set @insert_pivot=concat(															-- si prende NULL per l'auto_increment e tutti i dispositivi							
	' select NULL, D.Nome															 
	from (',@insert_pivot,') as D;'
	);
	
	set @insert_pivot = concat(															-- inserimento
	'INSERT INTO Pivot_Transazioni (',					
	@insert_pivot, ');'
	);
	
	prepare sql_statement from @insert_pivot;
	execute sql_statement;																-- avvenuta del popolamento


										-- ------------------------------------ --
										-- 	       ALGORITMO APRIORI			--
										-- ------------------------------------ -- 
                                        
                                        
                                        
drop table if exists Help_Me;
create table Help_Me(											-- Tabella dinamica ausiliaria
			I1 varchar(20)
);


drop table if exists Please;
create table Please (											-- ulteriore tabella d'appoggio 
			Device1 varchar(20)
);


drop table if exists NotEnough;
create table NotEnough (										-- Tabella proiettata ad ogni passo dell'algoritmo, 
			Items varchar(10000),								-- proietta dispositivi e il relativo supporto
            HowMany integer
);



-- Arrivati a questo punto dobbiamo iniziare ad implementare l'algoritmo Apriori, la prima tabella che si costruisce è una 
-- tabella di appoggio che per ogni dispositivo conta quante volte 

drop procedure if exists Apriori;
delimiter $$
create procedure Apriori(in _support double, in _confidence double)					-- il supporto è dato in input dall'utente
begin																				-- anche la confidenza 
		-- dichiarazioni variabili
        
        declare passo integer default 2; 											-- il passo iniziale deve essere minimo 2
        declare k integer default 0;												-- passo max k
        declare finito integer default 0;											-- variabile di uscita nei cursori
        declare stop double default 0;												-- variabile di uscita nei passi di join
		
        -- dichiarazioni cursori 
        
        declare scorri1 cursor for (
			select *
            from Help_Me
        );
        declare scorri_transazioni cursor for (
			select *
            from Transactions
        );
        declare scorri3 cursor for (
			select *
            from NotEnough
        );
        declare continue handler for not found set finito = 1;
        -- body
        truncate table Help_Me;														-- flushing della tabella di appoggio
		
        
		-- si deve creare una tabella che per ogni dispositivo ci calcoli l'occorrenza 
		create or replace view SupportItems as (
		select O.Dispositivo, Occorrenze / Totale as Support
		from (
				select D.Nome as Dispositivo, count(distinct I.Inizio) as Occorrenze
				from Interazione I natural join Dispositivo D
				group by D.Nome
		) as O
		cross join 
		(
					select count(*) as Totale
					from Pivot_Transazioni 
		) as D
		group by D.Nome
		);
		
        drop table if exists MinimalSupport;
        create temporary table if not exists MinimalSupport as (
			select SI.Dispositivo as Device
			from SupportItems SI
			where Support >= _support
		);
        drop view SupportItems;
        insert into Please (select * from MinimalSupport);
        
		set k = calcolo_k();														-- calcoliamo k con la funzione scritta prima
		set @variab_fetch = concat('@e1, @e', passo,';');							-- spiegato successivamente
        set @insert_enough = concat('INSERT INTO NotEnough values(concat(@e1), null);');
        while passo < k 
			do
            
				set @update_please = concat('alter Please add Device',passo, ' varchar(20);');
                
                set @update_help = concat('alter Help_Me add I',passo, ' varchar(20);');	-- ad ogni passo si aggiunge una colonna
                prepare sql_statement from @update_help;									-- alla tabella di appoggio
                execute sql_statement;
                truncate table Help_Me;
                insert into Help_Me(														-- si aggiorna la tabella di supporto 
					select *																-- questa è una prima parte del passo di join
                    from Please P cross join MinimalSupport MS								
					where P.Dispositivo <> MS.Dispositivo
                );
                
                
				select count(*) / 2 from Help_Me 
                into stop;																	-- le possibili combinazioni sono N!, a noi
																							-- però non interessa l'ordine, quindi valutiamo
				open scorri1;																-- solo N!/2 record	
				set @i = 0;
                

                -- queste variabili sono importanti nel fetch successivo
                set @fetching = concat('fetch scorri1 into ', @variab_fetch);
                
                -- alla prossima interazione avremo un fetch diverso
                set @variab_fetch = replace(@variab_fetch,';', concat(',@e', passo + 1 ,';'));
                
                -- si devono inserire nuovi dispositivi, quindi si fa un replace anche sul codice dinamico
                -- riguardante l'inserimento in NotEnough
                set @insert_enough = replace(@insert_enough,passo-1, concat(passo-1,',@e', passo, ')') );
                
                label: loop 
								if @i = stop then leave label;
                                end if;
                                set @i = @i + 1;
                                
                                -- il fetch di cui si parlava prima si fa in questa parte di codice, visto che ad ogni passo 
                                -- si aggiunge una colonna alla tabella di supporto, le variabili da prelevare aumentano, 
                                -- da qui deriva la scelta del fetch dinamico.
                                
								prepare sql_statement from @fetching;
                                execute sql_statement;
                                
                                -- si popola la tabella NotEnough
                                prepare sql_statement from @insert_enough;
                                execute sql_statement;
                                update NotEnough set HowMany = 0;	-- e si resetta il counter per il calcolo del support
					
                end loop label;
				
                close scorri1;
                
                -- a questo punto avremo nella tabella NotEnough le combinazioni dei dispositivi aventi al passo precedente 
                -- il supporto minimo accettato, adesso bisogna vedere se queste combinazioni possono essere supportate
                
                -- Per fare ciò si scorre la tabella Transazioni, la quale contiene per ogni riga una transazione,
                -- ovviamente bisogna scorrere anche la tabella NotEnough
                
                
                open scorri3;
                
                label: loop
                open scorri_transazioni;
                fetch scorri_item into f2;
                if finito = 1 then 
							leave label;
				end if;
						label1: loop 
						fetch scorri_transazioni into f3;
						if finito = 1 then 
								leave label1;
                        end if;
                        if (length(f2)-length(replace(f2,f3,'')))<>0 then			-- se viene trovata una corrispondenza, 
							update NotEnough set HowMany = HowMany + 1				-- si incrementa il valore identificante il supporto
                            where Items = f2;										-- del record analizzato
                            set @j = HowMany;
						end if;
                        end loop label1;
				if @j < _supporto*100 then											-- se tale supporto non raggiunge il minimo richiesto
					delete from NotEnough where Items = f2;							-- si elimina il record
				end if;
				close scorri_transazioni;
                set finito = 0;
                end loop label;
                
                close scorri_item;
                
                select * 															-- si proietta la tabella con le regole di  
                from NotEnough;														-- associazione con il relativo supporto
                
                set passo = passo + 1;
                
                truncate table Please;
                
                prepare sql_statement from @update_please;							-- aggiungiamo una colonna a Please 									
                execute sql_statement;
                
                insert into Please (												-- rendiamola uguale a Help_Me
					select * from Help_Me
                );
				prepare sql_statement from @update_help;									
                execute sql_statement;
                
				truncate NotEnough;
            
		end while;
        
        -- Drop delle tabelle che occupano molto spazio in memoria
        
        drop table if exists Help_Me;
        drop table if exists Transactions;
        drop table if exists Please;
        drop table if exists NotEnough;
        drop table if exists Pivot_Transazioni;



end $$
delimiter ;

call Apriori(0.01, 0.5);
