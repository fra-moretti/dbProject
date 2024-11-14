-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --

##################################################### BUSINESS RULES #####################################################################

-- Un determinato elemento di illuminazione non può avere più di 20 combinazioni di luce, (5 temperature e 4 intensità).

DROP TRIGGER IF EXISTS numproprietailluminatore;
DELIMITER $$
CREATE TRIGGER numproprietailluminatore
BEFORE INSERT ON ProprietaIlluminazione
FOR EACH ROW 
BEGIN
			DECLARE num_tot INTEGER;
            
            SELECT COUNT(*) INTO num_tot
            FROM ProprietaIlluminazione
            WHERE CodIlluminatore = NEW.CodIlluminatore;
            
            IF num_tot = 20 THEN
				
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = "L'illuminatore non puo' avere tutte queste proprieta'.";
			
            END IF;
            
            
END $$
DELIMITER ;


-- Le intensità e le temperature messe in Luce devono appartenere a quell'elemento di illuminazione

DROP TRIGGER IF EXISTS controllo_temp_int;
DELIMITER $$
CREATE TRIGGER controllo_temp_int
BEFORE INSERT ON Luce
FOR EACH ROW 
BEGIN
		IF NOT EXISTS (
        
						SELECT *
                        FROM ProprietaIlluminazione PI
                        WHERE PI.CodIlluminatore = NEW.CodIlluminatore AND PI.Intensita = NEW.Intensita AND
                        PI.Temperatura = NEW.Temperatura
                                
        ) THEN 
        
						SIGNAL SQLSTATE '45000'
						SET MESSAGE_TEXT = "L'illuminatore non dispone di tali impostazioni di disposizione di luce.";
                        
		END IF;
        
        
END $$
DELIMITER ;


-- Controllo che la scadenza del documento sia maggiore della data corrente

DROP TRIGGER IF EXISTS controllo_scadenza;
DELIMITER $$
CREATE TRIGGER controllo_scadenza
BEFORE INSERT ON DocumentoIdentita
FOR EACH ROW 
BEGIN
			IF (NEW.DataScadenza < CURRENT_DATE) THEN
					
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = "Documento scaduto!";
                    
            END IF;
            
END $$
DELIMITER ;

-- Controllo integrità dati anagrafici

DROP TRIGGER IF EXISTS check_anagr;
DELIMITER $$
CREATE TRIGGER check_anagr
BEFORE INSERT ON Utente
FOR EACH ROW 
BEGIN
		
        IF (NEW.DataNascita > CURRENT_DATE) THEN
					
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = "Data non consistente!";
                    
            END IF;
                
END $$
DELIMITER ;


-- Controllo che nell'archivio iscrizione vengono inserite date consistenti

DROP TRIGGER IF EXISTS controlla_data_isc;
DELIMITER $$
CREATE TRIGGER controlla_data_isc
BEFORE INSERT ON ArchivioIscrizioni
FOR EACH ROW 
BEGIN
			IF (NEW.DataIscrizione > CURRENT_DATE) THEN
					
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = "Data non consistente!";
                    
            END IF;
END $$
DELIMITER ;



-- Controllo che la data inserita nel condizionamento sia consistente

DROP TRIGGER IF EXISTS controlla_data_cond;
DELIMITER $$
CREATE TRIGGER controlla_data_cond
BEFORE INSERT ON Condizionamento
FOR EACH ROW 
BEGIN
			IF (NEW.DataAvvio > CURRENT_DATE) THEN
					
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = "Data non consistente!";
                    
            END IF;
            
            IF (NEW.DataAvvio > NEW.Spegnimento) THEN 
					SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = "Date non consistenti!";
			END IF;
            
END $$
DELIMITER ;

-- Controllo che la data inserita nella disposizione di luce sia consistente

DROP TRIGGER IF EXISTS controlla_data_luce;
DELIMITER $$
CREATE TRIGGER controlla_data_luce
BEFORE INSERT ON Luce
FOR EACH ROW 
BEGIN
			IF (NEW.DataInizio > CURRENT_DATE) THEN
					
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = "Data non consistente!";
                    
            END IF;
            
            IF (NEW.DataInizio > NEW.DataFine) THEN 
					SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = "Date non consistenti!";
			END IF;
            
END $$
DELIMITER ;


-- Gestione della smartplug

DROP TRIGGER IF EXISTS gestione_sp;
DELIMITER $$
CREATE TRIGGER gestione_sp
BEFORE INSERT ON SmartPlug
FOR EACH ROW 
BEGIN
			
            IF NOT EXISTS (
            
							SELECT *
                            FROM Dispositivo
                            WHERE NEW.Dispositivo = CodDispositivo
                            
            )	THEN
					
						SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = "Dispositivo non registrato nella smartHome";
            
            END IF;
            
            IF NOT EXISTS (
            
							SELECT *
                            FROM Stanza
                            WHERE NEW.Stanza = CodStanza
                            
            )	THEN
					
						SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = "Stanza non registrata nella smartHome";
            
            END IF;
            
            
            
END $$
DELIMITER ;

-- Gestione delle interazioni

DROP TRIGGER IF EXISTS gestione_int;
DELIMITER $$
CREATE TRIGGER gestione_int
BEFORE INSERT ON Interazione
FOR EACH ROW 
BEGIN
		
         IF NOT EXISTS (
            
							SELECT *
                            FROM Dispositivo
                            WHERE NEW.CodDispositivo = CodDispositivo
                            
            )	THEN
					
						SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = "Dispositivo non registrato nella smartHome";
            
            END IF; 
            
            IF (NEW.Inizio > CURRENT_DATE) THEN
					
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = "Data non consistente!";
                    
            END IF;
            
            IF (NEW.Inizio > NEW.Fine) THEN 
					SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = "Date non consistenti!";
			END IF;
            
            
END $$
DELIMITER ;

-- Gestione delle potenze

DROP TRIGGER IF EXISTS gestione_pot;
DELIMITER $$
CREATE TRIGGER gestione_pot
BEFORE INSERT ON Potenza
FOR EACH ROW 
BEGIN
			
            DECLARE num INTEGER;
            
			IF NOT EXISTS (
            
							SELECT *
                            FROM Dispositivo
                            WHERE NEW.Dispositivo = CodDispositivo
                            
            )	THEN
					
						SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = "Dispositivo non registrato nella smartHome";
            
            END IF; 
			
            SELECT COUNT(*) INTO num
            FROM Potenza
            WHERE Dispositivo = NEW.Dispositivo;
            
            IF num = 4 THEN
            
						SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = "Le potenze settate per il dispositivo hanno raggiunto il limite massimo";
            
            END IF;
            
            
END $$
DELIMITER ;


-- Gestione dei programmi

DROP TRIGGER IF EXISTS gestione_prog;
DELIMITER $$
CREATE TRIGGER gestione_prog
BEFORE INSERT ON Programma
FOR EACH ROW 
BEGIN
		
			DECLARE num INTEGER;
			IF NOT EXISTS (
            
							SELECT *
                            FROM Dispositivo
                            WHERE NEW.Dispositivo = CodDispositivo
                            
            )	THEN
					
						SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = "Dispositivo non registrato nella smartHome";
            
            END IF; 
            
            SELECT COUNT(*) INTO num
            FROM Programma
            WHERE NEW.Dispositivo = Dispositivo;
            
            IF num = 8 THEN 
					
						SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = "Il numero di programmi per quel dispositivo ha raggiunto il massimo";
            
            END IF;
			
            
            
END $$
DELIMITER ;

-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --

#################################################### AGGIORNAMENTO RIDONDANZE #############################################################


												-- Aggiornamento ConsumoMedio --
-- Si suppone che le potenze relative al dispositivo siano già inserite nel database: i trigger precedenti rendono ciò ammissibile.

DROP TRIGGER IF EXISTS update_consmedio;
DELIMITER $$
CREATE TRIGGER update_consmedio
AFTER INSERT ON Dispositivo
FOR EACH ROW 
BEGIN
			
            DECLARE consmedio DOUBLE;
            
            IF (NEW.Livello IS NOT NULL) THEN
            
				UPDATE Dispositivo
				SET ConsumoMedio = Livello
                WHERE NEW.CodDispositivo = CodDispositivo;
			
            ELSE
				
                SELECT AVG(Livello) INTO consmedio
                FROM Potenza
                WHERE Dispositivo = NEW.CodDispositivo;
                
                UPDATE Dispositivo
				SET ConsumoMedio = consmedio
                WHERE NEW.CodDispositivo = CodDispositivo;
            
            END IF;
            
END $$
DELIMITER ;



-- Il calcolo effettuato per il consumo di un'impostazione di condizionamento è ampiamente spiegato nell'appendice finale
-- della documentazione nel file 'Documentazione.pdf' 
DROP TRIGGER IF EXISTS update_consumo;
DELIMITER $$
CREATE TRIGGER update_consumo
AFTER INSERT ON Condizionamento
FOR EACH ROW 
BEGIN
			
            DECLARE coeff_disp DOUBLE DEFAULT 0.75;
			DECLARE energia_necessaria DOUBLE;
            DECLARE temperaturaint DOUBLE;
            DECLARE volume_stanza DOUBLE;
            
            SELECT (S.Lunghezza * S.Larghezza * S.Altezza), EE.TemperaturaInterna
            FROM Condizionamento C INNER JOIN ElementoDiCondizionamento EDC ON C.CodCondizionatore = EDC.Codice
            INNER JOIN Stanza S ON EDC.Stanza = S.CodStanza NATURAL JOIN EfficienzaEnergetica EE
            WHERE EDC.Codice = NEW.CodCondizionatore
            INTO volume_stanza, temperaturaint;
            
            UPDATE Condizionamento
            SET Consumo = (coeff_disp*(NEW.Temperatura - temperaturaint)*volume_stanza) / 860.61
            WHERE CodCondizonatore = NEW.CodCondizionatore AND DataAvvio = NEW.DataAvvio;
            
END $$
DELIMITER ;


-- Calcolo ridondanza CapacitaResidua

DROP EVENT IF EXISTS update_capacita;
DELIMITER $$
CREATE EVENT update_capacita ON SCHEDULE EVERY 1 DAY
STARTS '2022-02-22 23:59:59'
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
		
        OPEN scorri_batterie;
        
        label: LOOP 
			
					FETCH scorri_batterie INTO batteria_, capacita;
					
                    IF finito = 1 THEN
						LEAVE label;
					END IF;
                    
                    IF @energiadastoccare < capacita THEN
							
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
