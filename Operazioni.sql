                                           				
                                                        
																#1
############################################    		CREAZIONE ACCOUNT       #############################################################

-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --

DROP PROCEDURE IF EXISTS creazione_Account;
DELIMITER $$
CREATE PROCEDURE creazione_Account( IN Nome VARCHAR(50),
									IN Cognome VARCHAR(50),
                                    IN DataNascita DATE,
                                    IN Telefono VARCHAR(10),
                                    IN CodFiscale VARCHAR(16),
                                    IN NumDocumento VARCHAR(50),
                                    IN TipologiaDoc VARCHAR(50),
                                    IN DataScadenza DATE,
                                    IN EnteRilascio VARCHAR(50),
                                    IN Username VARCHAR(50),
                                    IN Password VARCHAR(50),
                                    IN Risposta VARCHAR(50)
                                    )
BEGIN
			DECLARE finito INTEGER DEFAULT 0;
            DECLARE domanda VARCHAR(50) DEFAULT '';
            DECLARE codD INTEGER;
            DECLARE scorri_domande CURSOR FOR (
					SELECT *
                    FROM DomandaDiSicurezza
            );
            
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
            
            -- Controllo sulla scadenza del documento identificativo
			IF DATEDIFF(DataScadenza, CURRENT_DATE) < 0 THEN
				SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Documento Scaduto, si prega di inserirne un altro valido';
			END IF;
			
            -- Controllo su lunghezza Password
            IF LENGTH(Password) <= 7 THEN
				SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La Password deve essere lunga almeno 8 caratteri';
			END IF;
             
			-- Controllo su lunghezza Username
			IF LENGTH(Username) <= 5 THEN
				SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Lo Username deve avere almeno 5 caratteri';
			END IF;
            
            -- Superati i controlli, passiamo alla scelta della domanda di sicurezza
            
            OPEN scorri_domande;
            
            label: LOOP
            
						FETCH scorri_domande INTO codD, domanda; 
					
						IF FINITO = 1 THEN
							LEAVE label;
						END IF;
                        
                        -- In questa parte abbiamo creato una simulazione di scelta: se la funzione scritta RAND (*100) ritorna
                        -- un numero divisibile per 3, è come se l'utente avesse scelto quella domanda
                        
                        IF NOT(FLOOR(RAND()*100) % 3) THEN 
                            SET @domanda_scelta = domanda;
                            SET @codice_scelto = codD;
                            LEAVE label;
						END IF;
								
            
            END LOOP;
            
			CLOSE scorri_domande;
            
            -- Vi e' la remota probabilità che non venga mai ritornato un numero pari, questo è visto come 
            -- se l'utente non abbia scelto una domanda
            IF finito = 1 THEN 		
				SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Per avanzare nella iscrizione deve scegliere una domanda di sicurezza';
            
            -- Ora possiamo procedere alla scrittura nelle tabelle
            ELSE
				INSERT INTO Utente VALUES (CodFiscale, Nome, Cognome, DataNascita, Telefono);
				INSERT INTO Account VALUES (Username, Password, @codice_scelto, Risposta);
				INSERT INTO DocumentoIdentita VALUES (TipologiaDoc, NumDocumento, EnteRilascio, DataScadenza, Username, CodFiscale);
				INSERT INTO ArchivioIscrizioni VALUES (CodFiscale, Username, CURRENT_DATE);
            END IF;
END $$
DELIMITER ;

-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --


															   #2
###################################    		 INSERIMENTO DISPOSITIVO INTELLIGENTE	       ###############################################

-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --

DROP PROCEDURE IF EXISTS insert_smart_device;
DELIMITER $$
CREATE PROCEDURE insert_smart_device ( IN Dispositivo INTEGER, 
									   IN funzionalita VARCHAR(20), 
									   IN tipo VARCHAR(8), 
									   IN livello INTEGER, 
									   IN Stanza INTEGER )
BEGIN 

			DECLARE finito INTEGER DEFAULT 0;
			DECLARE codsmartplug INTEGER;
            DECLARE dispsmartplug INTEGER;
            DECLARE stanzasmartplug INTEGER;
            
            DECLARE scorri_plug CURSOR FOR (
					SELECT *
                    FROM SmartPlug
            );
            DECLARE scorri_temptable CURSOR FOR (
					SELECT SmartPlug
                    FROM StanzeSmartPlugLibero
            );
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
            
            CREATE TEMPORARY TABLE IF NOT EXISTS StanzeSmartPlugLibero (
					SmartPlug INTEGER NOT NULL PRIMARY KEY,
                    Stanza INTEGER NOT NULL
            );
            
            TRUNCATE TABLE StanzeSmartPlugLibero;
            
            OPEN scorri_plug;
            
            -- Scorriamo le smart plug
            label: LOOP
							
					FETCH scorri_plug INTO codsmartplug, dispsmartplug, stanzasmartplug;
					IF finito = 1 THEN 
						LEAVE label;
					END IF;
                    -- Abbiamo una smart plug libera nella stanza interessata ?
                    IF dispsmartplug IS NULL AND stanzasmartplug = Stanza THEN
								UPDATE SmartPlug SP
                                SET SP.Dispositivo = Dispositivo
                                WHERE SP.Codice = codsmartplug;
								LEAVE label;
                    END IF;
                    
                    -- Abbiamo una smart plug libera ma in un'altra stanza ?
                    IF dispsmartplug IS NULL AND stanzasmartplug <> Stanza THEN
								SET @i = 1; 										-- variabile di appoggio, ci servirà dopo
								INSERT INTO StanzeSmartPlugLibero VALUES (codsmartplug, stanzasmartplug);
                    END IF;
					
            END LOOP;
            
            CLOSE scorri_plug;
            
            -- Nel caso in cui abbiamo trovato solo smart plug in altre stanze, si scorre la tabella temporanea creata
            -- e l'utente sceglierà quale smart plug prendere
            IF finito = 1 AND @i = 1 THEN
				SET finito = 0;
				OPEN scorri_temptable;
                
				label: LOOP
							FETCH scorri_temptable INTO codsmartplug;
                            
							IF finito = 1 THEN 
									LEAVE label;
                            END IF;
                            
                            -- Simuliamo la scelta come abbiamo fatto prima con la creazione dell'account
                            -- in questo caso si sceglie quello smart plug situato in una determinata stanza
                            
                             IF NOT(FLOOR(RAND()*100) % 3) THEN  
                             
									SET @plug_scelto = codsmartplug;
									LEAVE label;
                             
                             END IF;
                    
                END LOOP;
                
                CLOSE scorri_temptable;
                
                -- Anche in questo caso c'e' la remota probabilità che non venga mai ritornato un numero pari, questo è visto come 
				-- se l'utente non abbia scelto uno smart plug idoneo
				IF finito = 1 THEN
                
						SIGNAL SQLSTATE '45000'
						SET MESSAGE_TEXT = 'Devi scegliere uno smart plug per poter rendere il dispositivo intelligente';
				               
                ELSE 
                
								UPDATE SmartPlug SP
                                SET SP.Dispositivo = Dispositivo AND SP.Stanza = Stanza
                                WHERE SP.Codice = codsmartplug;
                                
                                -- Insieriamo il dispositivo
                                INSERT INTO Dispositivo VALUES (NULL, funzionalita, tipo, livello);
                                
                END IF;
					
            -- In questo caso non vi è nessuna smart plug libera, sono tutte occupate. Si avvisa l'utente
            ELSEIF finito = 1 THEN 
            
				SET @niente = 'Non ci sono smart plug libere';
                SELECT @niente;
                
			-- In questo caso abbiamo avuto una leave prima di finire di scorrere la tabella, quindi vi è uno smart plug libero
            -- nella stanza messa in input. Si effettua l'inserimento nella tabella Dispositivo
            ELSE 
            
				INSERT INTO Dispositivo VALUES (NULL, funzionalita, tipo, livello);
                
            END IF;
				
END $$
DELIMITER ;

-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --
		
        
                                                                #3
#######################################    		 	VERIFICA STATO SERRAMENTI	       		###############################################

DROP PROCEDURE IF EXISTS verifica_serramenti;
DELIMITER $$
CREATE PROCEDURE verifica_serramenti( IN stanza INTEGER )
BEGIN
		
        DECLARE nomes_ VARCHAR(20);
        DECLARE nomec_ VARCHAR(20);
        DECLARE stato_ TINYINT;
        DECLARE finito INTEGER;
        DECLARE scorri_serramenti CURSOR FOR (
			SELECT S.Nome, CE.Nome, IF(LAST_VALUE(S.TChiusura) OVER w IS NULL, 1, 0)	-- si prendono i nomi dei collegamenti esterni e lo stato dei rispettivi serramenti
            FROM CollegamentoEsterno CE NATURAL JOIN Serramento S
            WHERE CE.Stanza = stanza
            WINDOW w AS (ORDER BY S.TApertura ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
        ); 
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
        
		CREATE TEMPORARY TABLE IF NOT EXISTS stato_serramenti(
				Stato VARCHAR(60)
        );
        
        TRUNCATE TABLE stato_serramenti;
        
        OPEN scorri_serramenti;
        
        label: LOOP 	
        
						FETCH scorri_serramenti INTO nomes_, nomec_, stato_;
						IF finito = 1 THEN
							LEAVE label;
                        END IF;
                        
                        INSERT INTO stato_serramenti VALUES (CONCAT(
                        'Le ', nomes_, IF(nomec_='Finestra' or nomec_='PortaFinestra', 'della', 'del'),
                        nomec_, 'sono ', if(stato_ = 1, 'aperte.', 'chiuse.')
                        ));
                        
        END LOOP;
        
        CLOSE scorri_serramenti;
        
        SELECT * FROM stato_serramenti;		-- si mostra il tutto a video
		
END $$
DELIMITER ;

-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --


                                                                 #4
#######################################    		 		SINCRONIZZAZIONE LUCI    		###################################################

DROP PROCEDURE IF EXISTS sincronizzazione_luci;
DELIMITER $$
CREATE PROCEDURE sincronizzazione_luci( IN account_ VARCHAR(20), 
										IN stanza_ INTEGER,
                                        IN temperatura_ VARCHAR(20),
                                        IN intensita_ VARCHAR(20))
BEGIN
			DECLARE finito INTEGER DEFAULT 0;
            DECLARE illuminatore INTEGER;
			DECLARE scorri_luci CURSOR FOR ( 
				
                SELECT EDI.Codice
                FROM ElementoDiIlluminazione EDI
                WHERE EDI.Stanza = stanza_
                
            ); 
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
			
            label: LOOP
					
                    FETCH scorri_luci INTO illuminatore;
                    
					IF finito = 1 THEN
							LEAVE label;
                    END IF;
                    
                    IF NOT EXISTS (					-- se il dispositivo non può avere quella intensità o quella temperatura
										SELECT *
                                        FROM ProprietaIlluminazione PI
                                        WHERE PI.CodIlluminatore = illuminatore AND PI.Intensita = intensita_ 
                                        AND PI.Temperatura = temperatura_
                    ) THEN 		
								SET @messaggio = CONCAT("La temperatura o la intensita' del dispositivo ", illuminatore, 
                                "non puo' essere impostata.");
								SIGNAL SQLSTATE '45000'
                                SET MESSAGE_TEXT = @messaggio;
                    END IF;
                    
                    IF EXISTS (									-- se è già acceso
								SELECT *
                                FROM Luce L
                                WHERE L.CodIlluminatore = illuminatore AND L.DataFine IS NULL
                    ) THEN
							
								UPDATE Luce
                                SET Account = account_ AND Temperatura = temperatura_ AND Intensita = intensita_
                                WHERE CodIlluminatore = illuminatore;
                    ELSE 
								INSERT INTO Luce VALUES(illuminatore, CURRENT_DATE, account_, temperatura, intensita_, NULL);
                    END IF;
            
            END LOOP;
END $$
DELIMITER ;

-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --


                                                                 #5
#######################################    		 		CLASSIFICA DISPOSITIVI    		    ###############################################

-- Questa operazione è stata notevolmente ottimizzata con l'aggiunta della ridondanza 'ConsumoMedio' in Dispositivo.
-- L'aggiornamento della ridondanza è implementato tramite trigger nella sezione apposita 'Trigger.sql'

DROP EVENT IF EXISTS ranking_device;
DELIMITER $$
CREATE EVENT ranking_device ON SCHEDULE EVERY 1 MONTH
STARTS '2022-03-01 00:00:00'
DO
BEGIN
        SELECT D.Dispositivo, Consumo, RANK() OVER w AS Ranking_Consumo_Dispositivi
        FROM (
			SELECT I.Dispositivo, D.Tipo, SUM(D.ConsumoMedio) AS Consumo
			FROM Interazione I NATURAL JOIN Dispositivo D
			WHERE I.Inizio + INTERVAL 1 MONTH >= CURRENT_DATE
			GROUP BY I.Dispositivo
		) AS D
        WINDOW w AS (ORDER BY D.Consumo);
END $$
DELIMITER ;
        
-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --


																     #6
#######################################    		  	 CONSUMO IMPOSTAZIONE CONDIZIONAMENTO    		    ###################################

-- Anche questa operazione è stata semplificata tramite l'uso di una ridondanza, 
-- ovviamente l'aggiornamento è implementato nella parte specifica

DROP PROCEDURE IF EXISTS consumo_condizionamento;
DELIMITER $$
CREATE PROCEDURE consumo_condizionamento( IN condizionatore INTEGER )
BEGIN
		
        SELECT SUM(C.Consumo) AS Consumo
        FROM Condizionamento C
        WHERE C.DataAvvio + INTERVAL 1 DAY > CURRENT_DATE AND C.CodCondizionatore = condizionatore
        GROUP BY C.CodCondizionatore;
        
END $$
DELIMITER ;

-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --


																	#7
#######################################    		  		   STOCCAGGIO GIORNALIERO  		   		  #########################################
DROP EVENT IF EXISTS stocc_energia;
DELIMITER $$
CREATE EVENT stocc_energia ON SCHEDULE EVERY 1 DAY
DO
BEGIN
		DECLARE batteria_ INTEGER;
        DECLARE energia_consumata DOUBLE;
        DECLARE energia_prodotta DOUBLE;
        DECLARE capacita DOUBLE;
        DECLARE finito INTEGER DEFAULT 0;
        
        DECLARE scorri_batterie CURSOR FOR (
			SELECT B.CodBatteria, B.CapacitaResidua
            FROM Batteria B
		);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
        
		SELECT SUM(C.Quantita) 
		FROM Consumo C
        WHERE DATE(C.Timestamp) = CURRENT_DATE
        INTO energia_consumata;
        
		SELECT SUM(P.Livello) 
		FROM Produzione P
		WHERE DATE(P.Timestamp) = CURRENT_DATE
        INTO energia_prodotta;
        
        SET @energia_da_stoccare=energia_prodotta-energia_consumata;
        
        OPEN scorri_batterie;
        
        label: LOOP 
			
					FETCH scorri_batterie INTO batteria_, capacita;
					
                    IF finito = 1 THEN
						LEAVE label;
					END IF;
                    
                    IF @energiadastoccare < capacita THEN
							
                            INSERT INTO Stoccaggio VALUES (batteria_, CURRENT_TIMESTAMP); 
                            UPDATE Batteria 
                            SET CapacitaResidua = CapacitaResidua - @energiadastoccare
                            WHERE CodBatteria = batteria_;
                            LEAVE label;
                            
                    END IF;
                    
        END LOOP;
        
        CLOSE scorri_batterie;
        
		IF finito = 1 THEN 
				
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT='Batterie Piene';
                
        END IF;
        
END $$
DELIMITER ;

-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --
																     
                                                                     
                                                                     #8
###########################################    		  	 	   CALCOLO STORNO    		    		########################################


DROP EVENT IF EXISTS storno_bolletta;
DELIMITER $$
CREATE EVENT storno_bolletta ON SCHEDULE EVERY 1 MONTH
STARTS '2022-03-01 00:00:00'
DO
BEGIN
		DECLARE energia_consumata DOUBLE;
        DECLARE energia_prodotta DOUBLE;
        
        SELECT SUM(C.Quantita) 
		FROM Consumo C
        WHERE DATE(C.Timestamp) + INTERVAL 1 MONTH > CURRENT_DATE
        INTO energia_consumata;
        
		SELECT SUM(P.Livello) 
		FROM Produzione P
		WHERE DATE(P.Timestamp) + INTERVAL 1 MONTH > CURRENT_DATE
        INTO energia_prodotta;
        
        SELECT * INTO @codrete 			-- sappiamo che è unica
        FROM ReteElettrica;
        
        IF (energia_prodotta > energia_consumata) THEN
			INSERT INTO Immissione VALUES (@codrete, CURRENT_TIMESTAMP);
			SET @storno = 0.1264 * (energia_prodotta - energia_consumata);		-- calcolo storno tramite prezzo medio energia al Kwh
            SELECT @storno;
        END IF;
        
        
END $$
DELIMITER ;

-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --
