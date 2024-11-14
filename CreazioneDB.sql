# SET FOREIGN_KEY_CHECKS = 0;
drop database if exists Smarthome;
create database Smarthome;
use Smarthome;


#---------------------------|
#		AREA GENERALE		|
#---------------------------|

drop table if exists Utente;
create table Utente ( 
    CodFiscale varchar(16) primary key,  
    Nome varchar(50) not null, 
    Cognome varchar(50) not null, 
    DataNascita date not null, 
    Telefono varchar(10) 
	) engine = InnoDB default charset = latin1; 
    
insert into Utente (CodFiscale, Nome, Cognome, DataNascita, Telefono)
values ("VLPFNC70C23D024E", "Francesco", "Volpe", "1970-03-23", 3334049247),
	   ("GTTFLV74A16G731B", "Flavia",    "Gatta", "1974-01-16", 3345463865),
	   ("VLPTMS97P08G702B", "Tommaso",   "Volpe", "1997-09-08", 3476732076),
       ("VLPSFO01H57G702I", "Sofia",     "Volpe", "2001-06-17", 3457839274),
       ("PLAVLP17C25G702G", "Paolo",     "Volpe", "2017-03-25", NULL);

drop table if exists DomandaDiSicurezza;
create table DomandaDiSicurezza(
	CodDomanda int auto_increment not null primary key,
    Testo varchar(50) not null
    )engine = InnoDB default charset = latin1;
    
insert into DomandaDiSicurezza (Testo)
values  ("Primo lavoro svolto?"), 
        ("Cognome da nubile di tua madre?"), 
        ("Nome del tuo primo animale?"), 
        ("Colore preferito?"), 
        ("Nome del tuo primo amore?"),
        ("Nome dell'amico del cuore?"),
        ("Città preferita?"),
        ("Nome della tua squadra del cuore?"); 
        


drop table if exists Account;
create table Account ( 
    Username varchar (50) primary key,  
    Password varchar (50) not null, 
    Domanda int not null,  
    Risposta varchar(50) not null,  
    foreign key (Domanda) references DomandaDiSicurezza(CodDomanda) 
    on delete no action
    on update no action
	)engine = InnoDB default charset = latin1; 
    
insert into Account (Username, Password, Domanda, Risposta)
values ("FrancescoVolpe70", "azerc28", 5, "Giulia"),
	   ("FlaviaGatta74", "nigurg46", 3, "Scheggia"),
       ("TommasoVolpe97", "ghrymab4", 2, "Fiore"),
       ("SofiaVolpe01", "nhferni78", 7, "Venezia");


drop table if exists DocumentoIdentita;
create table DocumentoIdentita ( 
	Tipologia varchar(50) check (Tipologia in ('CartaIdentita', 'Passaporto', 'Patente')), 
    Numero	varchar(50), 
    EnteRilascio varchar(50) not null, 
    DataScadenza date not null ,  
    Account varchar(50) not null, 
    CodFiscale varchar(16) not null, 
    primary key(Tipologia, Numero), 
    foreign key (Account) references Account(Username)
    on delete no action
    on update no action,
    foreign key (CodFiscale) references Utente(CodFiscale) 
    on delete no action
    on update no action
	)engine = InnoDB default charset = latin1; 

insert into DocumentoIdentita (Tipologia, Numero, EnteRilascio, DataScadenza, Account, CodFiscale)
values ("CartaIdentita", "BE80957804", "MinisterodellInterno", "2028-04-23", "FrancescoVolpe70","VLPFNC70C23D024E"),
       ("CartaIdentita", "ZE13858917", "MinisterodellInterno", "2027-10-31", "FlaviaGatta74",   "GTTFLV74A16G731B"),
       ("CartaIdentita", "OM27288173", "MinisterodellInterno", "2031-06-02", "TommasoVolpe97",  "VLPTMS97P08G702B"),
       ("CartaIdentita", "QA65194904", "MinisterodellInterno", "2029-01-06", "SofiaVolpe01",    "VLPSFO01H57G702I");

drop table if exists Stanza;
create table Stanza ( 
    CodStanza int auto_increment not null primary key, 
    Nome varchar(50) not null, 
    Ubicazione tinyint not null,
    Lunghezza double not null, 
    Larghezza double not null, 
    Altezza double not null
	) engine = InnoDB default charset = latin1; 
    
insert into Stanza (Nome, Ubicazione, Lunghezza, Larghezza, Altezza)
values ("Ingresso",  1, 7,    2.50, 3.40), 
	   ("Cucina",    1, 4.20, 5,    3.40), 
       ("Salone",    1, 4.50, 6.50, 3.40), 
       ("Bagno",     1, 3.70, 4,    3.40), 
       ("Camera",    1, 4,    5.50, 3.40), 
       ("Studio",    2, 3.50, 3,    3.10), 
       ("Bagno",     2, 2.50, 2.30, 3.10), 
       ("Cameretta", 2, 3,    2.50, 3.10), 
       ("Cameretta", 2, 2.80, 3.20, 3.10);



drop table if exists CollegamentoEsterno;
create table CollegamentoEsterno ( 
    Codice int auto_increment not null primary key, 
    Nome varchar(20) not null,
    Stanza int not null, 
    PuntoCardinale varchar(2) check (PuntoCardinale in ('N', 'NE', 'NO', 'S', 'SE', 'SO', 'E', 'O')), 
    foreign key (Stanza) references Stanza(CodStanza) 
    on delete no action
    on update no action
	)engine = InnoDB default charset = latin1; 
    
insert into CollegamentoEsterno (Nome, Stanza, PuntoCardinale)
values ("Finestra", 1, "NE"), 
       ("PortaFinestra", 2, "NO"), 
       ("Finestra", 2, "NE"), 
       ("Finestra", 3, "SO"), 
       ("PortaFinestra", 3, "SE"), 
       ("Finestra", 3, "SE"), 
       ("PortaFinestra", 4, "NO"), 
       ("Finestra", 5, "NE"), 
       ("Finestra", 5, "NO"), 
       ("PortaFinestra", 6, "SE"), 
       ("Finestra", 6, "SO"), 
       ("PortaFinestra", 7, "SE"), 
       ("Finestra", 8, "NE"), 
       ("Finestra", 9, "NE"), 
       ("PortaFinestra", 9, "NO");


drop table if exists ArchivioIscrizioni;
create table ArchivioIscrizioni (
	CodFiscale varchar(16),
    Username varchar (50),
    DataIscrizione date not null,
    foreign key (CodFiscale) references Utente(CodFiscale)
    on delete no action
    on update no action,
    foreign key (Username) references Account(Username)
    on delete no action
    on update no action
    )engine = InnoDB default charset = latin1;
    
insert into ArchivioIscrizioni (CodFiscale, Username, DataIscrizione)
values ("VLPFNC70C23D024E", "FrancescoVolpe70", "2019-09-13"),
	   ("GTTFLV74A16G731B", "FlaviaGatta74", "2019-09-13"),
       ("GTTFLV74A16G731B", "TommasoVolpe97", "2019-09-15"),
       ("GTTFLV74A16G731B", "SofiaVolpe01", "2019-09-16")
       ;

drop table if exists Porta;
create table Porta (
	CodPorta int auto_increment primary key
	)engine = InnoDB default charset = latin1;

insert into Porta values (null), (null), (null), (null), (null), (null), (null), (null), (null), (null); 

drop table if exists Accesso;
create table Accesso (
	CodStanza int not null,
	CodPorta int not null,
	foreign key (CodStanza) references Stanza(CodStanza)
	on delete no action
    on update no action,
    foreign key (CodPorta) references Porta(CodPorta)
    on delete no action
    on update no action
    )engine = InnoDB default charset = latin1;
    

insert into Accesso (CodStanza, CodPorta)
values (1,1), (3,1), (1,2), (2,2), (3,3), (5,3), (1,4), (4,4), (1,5), (5,5), 
(6,6), (7,6), (6,7), (8,7), (6,8), (9,8), (7,9), (8,9), (8,10), (9,10);
        

drop table if exists ElementodiCondizionamento;
create table ElementodiCondizionamento (
	Codice int auto_increment not null primary key,
    ConsumoMedio double not null,
    Stanza int not null,
    foreign key (Stanza) references Stanza(CodStanza)
    on delete no action
    on update no action
    )engine = InnoDB default charset = latin1;
    
insert into ElementodiCondizionamento (ConsumoMedio, Stanza)
values (547,2),(532,3),(587,4),(502,5),(498,6),(512,7),(524,8),(467,9);


drop table if exists EfficienzaEnergetica;
create table EfficienzaEnergetica (
	Timestamp timestamp not null,
	CodStanza int not null,
	TemperaturaInterna double not null check (TemperaturaInterna between 18 and 30),
	TemperaturaEsterna double not null,
	foreign key (CodStanza) references Stanza(CodStanza)
    on delete no action
    on update no action,
    primary key(Timestamp, CodStanza)
    )engine = InnoDB default charset = latin1;

insert into EfficienzaEnergetica (Timestamp, CodStanza, TemperaturaInterna, TemperaturaEsterna)
values 
		#stanza2
       ("2022-02-22 0",2,19,10.1),  ("2022-02-22 2",2,19,8),  ("2022-02-22 4",2,19,7.3), ("2022-02-22 6",2,19,9.4),
       ("2022-02-22 8",2,19,10.2),  ("2022-02-22 10",2,19,11.3), ("2022-02-22 12",2,19,14.4), ("2022-02-22 14",2,19,15.3), 
       ("2022-02-22 16",2,19,14.2), ("2022-02-22 18",2,19,12), ("2022-02-22 20",2,19,11.4), ("2022-02-22 22",2,19,10.3), 
       
        #stanza3
       ("2022-02-22 0",3,19,10.1),  ("2022-02-22 2",3,19,8),  ("2022-02-22 4",3,19,7.3), ("2022-02-22 6",3,19,9.4), 
       ("2022-02-22 8",3,19,10.2),  ("2022-02-22 10",3,19,11.3), ("2022-02-22 12",3,19,14.4), ("2022-02-22 14",3,19,15.3), 
       ("2022-02-22 16",3,19,14.2), ("2022-02-22 18",3,19,12), ("2022-02-22 20",3,19,11.4), ("2022-02-22 22",3,19,10.3), 

        #stanza4
       ("2022-02-22 0",4,19,10.1),  ("2022-02-22 2",4,19,8),  ("2022-02-22 4",4,19,7.3), ("2022-02-22 6",4,19,9.4), 
       ("2022-02-22 8",4,19,10.2),  ("2022-02-22 10",4,19,11.3), ("2022-02-22 12",4,19,14.4), ("2022-02-22 14",4,19,15.3), 
       ("2022-02-22 16",4,19,14.2), ("2022-02-22 18",4,19,12), ("2022-02-22 20",4,19,11.4), ("2022-02-22 22",4,19,10.3), 

        #stanza5
       ("2022-02-22 0",5,19,10.1),  ("2022-02-22 2",5,19,8),  ("2022-02-22 4",5,19,7.3), ("2022-02-22 6",5,19,9.4), 
       ("2022-02-22 8",5,19,10.2),  ("2022-02-22 10",5,19,11.3), ("2022-02-22 12",5,19,14.4), ("2022-02-22 14",5,19,15.3), 
       ("2022-02-22 16",5,19,14.2), ("2022-02-22 18",5,19,12), ("2022-02-22 20",5,19,11.4), ("2022-02-22 22",5,19,10.3), 

        #stanza6
       ("2022-02-22 0",6,19,10.1),  ("2022-02-22 2",6,19,8),  ("2022-02-22 4",6,"19",7.3), ("2022-02-22 6","6","19",9.4),
       ("2022-02-22 8",6,19,10.2),  ("2022-02-22 10",6,19,11.3), ("2022-02-22 12",6,"19",14.4), ("2022-02-22 14","6","19",15.3),  
       ("2022-02-22 16",6,19,14.2), ("2022-02-22 18",6,19,12), ("2022-02-22 20",6,"19",11.4), ("2022-02-22 22","6","19",10.3),

        #stanza7
       ("2022-02-22 0",7,19,10.1),  ("2022-02-22 2",7,19,8),  ("2022-02-22 4",7,"19",7.3), ("2022-02-22 6","7","19",9.4), 
       ("2022-02-22 8",7,19,10.2),  ("2022-02-22 10",7,19,11.3), ("2022-02-22 12",7,"19",14.4), ("2022-02-22 14","7","19",15.3),
       ("2022-02-22 16",7,19,14.2), ("2022-02-22 18",7,19,12), ("2022-02-22 20",7,"19",11.4), ("2022-02-22 22","7","19",10.3),

        #stanza8
       ("2022-02-22 0",8,19,10.1),  ("2022-02-22 2",8,19,8),  ("2022-02-22 4",8,"19",7.3), ("2022-02-22 6","8","19",9.4),
       ("2022-02-22 8",8,19,10.2),  ("2022-02-22 10",8,19,11.3), ("2022-02-22 12",8,"19",14.4), ("2022-02-22 14","8","19",15.3),
       ("2022-02-22 16",8,19,14.2), ("2022-02-22 18",8,19,12), ("2022-02-22 20",8,"19",11.4), ("2022-02-22 22","8","19",10.3),

        #stanza9
       ("2022-02-22 0",9,19,10.1),  ("2022-02-22 2",9,19,8),  ("2022-02-22 4",9,"19",7.3), ("2022-02-22 6","9","19",9.4),
       ("2022-02-22 8",9,19,10.2),  ("2022-02-22 10",9,19,11.3), ("2022-02-22 12",9,"19",14.4), ("2022-02-22 14","9","19",15.3),  
       ("2022-02-22 16",9,19,14.2), ("2022-02-22 18",9,19,12), ("2022-02-22 20",9,"19",11.4), ("2022-02-22 22","9","19",10.39);


#---------------------------|
#      AREA DISPOSITIVI 	|
#---------------------------|


drop table if exists Dispositivo;
create table Dispositivo (
	CodDispositivo int auto_increment not null primary key,
    Funzionalità varchar(50) not null,
    Tipo enum('fisso', 'variabile') not null,
    Livello double,
    ConsumoMedio double default null
    )engine = InnoDB default charset = latin1;

    
insert into Dispositivo (Funzionalità, Tipo, Livello)
values ("Aspirapolvere","fisso",1.300), ("Macchinacaffe","fisso",0.350), ("Televisore","fisso",0.300), ("Televisore","fisso",0.500), ("Televisore","fisso",0.400), ("Ferrodastiro","fisso",0.470), 
       ("Frullatore","fisso",0.200), ("Macchinacaffe","fisso",0.700), ("Forno","fisso",0.800), ("Tostapane","fisso",0.290), ("Computer","fisso",0.700), ("Computer","fisso",0.670), ("Computer","fisso",0.750), 
       ("Scaldabagno","fisso",0.870),("Tostapane","fisso",0.340), ("Stereo","fisso",0.350), ("Stereo","fisso",360), ("Radio","fisso",300), 
       
       ("Microonde","variabile",null), ("Ventilatore","variabile",null), ("Ventilatore","variabile",null), ("Stufetta","variabile",null), ("Stufetta","variabile",null), ("Lavatrice","variabile",null),
       ("Ventilatore","variabile",null), ("Phon","variabile",null), ("Lavastoviglie","variabile",null), ("Aspirapolvere","variabile",null), ("Asciugatrice","variabile",null), ("Lavatrice","variabile",null);
    

    

drop table if exists Interazione;
create table Interazione (
	Inizio timestamp,
	Fine timestamp,
    Account varchar (50) not null,
    CodDispositivo int not null,
    primary key (Inizio, Account, CodDispositivo),
    foreign key (Account) references Account (Username)
    on delete no action
    on update no action,
    foreign key (CodDispositivo) references Dispositivo(CodDispositivo)
	on delete no action
    on update no action
    )engine = InnoDB default charset = latin1;
    
insert into Interazione (Inizio, Fine, Account, CodDispositivo)
values  

		("2022-02-22 7:30:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 1), ("2022-02-22 8:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 4),  ("2022-02-22 7:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 6),  ("2022-02-22 8:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 8),
       ("2022-02-22 8:37:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 9),  ("2022-02-22 9:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 16), ("2022-02-22 9:15:00", "2022-02-22 21:47", "TommasoVolpe97", 11), ("2022-02-22 9:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 2),
       ("2022-02-22 9:31:00", "2022-02-22 22:47:31", "FrancescoVolpe70", 4), ("2022-02-22 9:32:00", null, "FlaviaGatta74", 9),  ("2022-02-22 9:42:00", "2022-02-22 21:47", "TommasoVolpe97", 18), ("2022-02-22 9:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 14),
       ("2022-02-22 12:30:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 8), ("2022-02-22 12:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 3),  ("2022-02-22 12:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 3),  ("2022-02-22 12:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 1),
       ("2022-02-22 13:10:00", null, "FrancescoVolpe70", 15), ("2022-02-22 13:14:00", "2022-02-22 23:59:59", "FlaviaGatta74", 13),  ("2022-02-22 13:42:00", null, "TommasoVolpe97", 18),  ("2022-02-22 13:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 21),
       ("2022-02-22 14:37:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 19),  ("2022-02-22 14:20:00", "2022-02-22 23:59:59", "FlaviaGatta74", 18), ("2022-02-22 14:15:00", "2022-02-22 23:59:59", "TommasoVolpe97", 12), ("2022-02-22 14:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 14),
       ("2022-02-22 21:31:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 21), ("2022-02-22 22:32:00", null, "FlaviaGatta74", 20),  ("2022-02-22 22:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 19), ("2022-02-22 22:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 17),
       ("2022-02-22 23:30:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 8), ("2022-02-22 23:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 2),  ("2022-02-22 23:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 21),  ("2022-02-22 23:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 13),
       ("2022-02-23 8:37:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 9),  ("2022-02-23 9:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 16), ("2022-02-23 9:15:00", "2022-02-22 23:59:59", "TommasoVolpe97", 11), ("2022-02-23 9:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 2),
       ("2022-02-23 7:30:00", "2022-02-22 22:47:31", "FrancescoVolpe70", 1), ("2022-02-23 8:10:00", null, "FlaviaGatta74", 4),  ("2022-02-23 7:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 6),  ("2022-02-23 8:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 8),
       ("2022-02-23 9:31:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 4), ("2022-02-23 9:32:00", "2022-02-22 23:59:59", "FlaviaGatta74", 9),  ("2022-02-23 9:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 18), ("2022-02-23 9:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 14),
       ("2022-02-23 12:30:00", null, "FrancescoVolpe70", 8), ("2022-02-23 12:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 3),  ("2022-02-23 12:42:00", null, "TommasoVolpe97", 3),  ("2022-02-23 12:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 1),
       ("2022-02-23 13:10:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 15), ("2022-02-23 13:14:00", "2022-02-22 23:59:59", "FlaviaGatta74", 13),  ("2022-02-23 13:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 18),  ("2022-02-23 13:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 21),
       ("2022-02-23 14:37:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 19),  ("2022-02-23 14:20:00", null, "FlaviaGatta74", 18), ("2022-02-23 14:15:00", "2022-02-22 23:59:59", "TommasoVolpe97", 12), ("2022-02-23 14:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 14),
       ("2022-02-23 21:31:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 21), ("2022-02-23 22:32:00", "2022-02-22 23:59:59", "FlaviaGatta74", 20),  ("2022-02-22 23:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 19), ("2022-02-23 22:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 17),
       ("2022-02-23 23:30:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 8), ("2022-02-23 23:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 2),  ("2022-02-23 23:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 21),  ("2022-02-23 23:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 13),
       
       ("2022-02-24 7:30:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 1), ("2022-02-24 8:10:00", null, "FlaviaGatta74", 4),  ("2022-02-24 7:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 6),  ("2022-02-24 8:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 8),
       ("2022-02-24 8:37:00", "2022-02-22 22:47:31", "FrancescoVolpe70", 9),  ("2022-02-24 9:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 16), ("2022-02-24 9:15:00", "2022-02-22 23:59:59", "TommasoVolpe97", 11), ("2022-02-24 9:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 2),
       ("2022-02-24 9:31:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 4), ("2022-02-24 9:32:00", "2022-02-22 23:59:59", "FlaviaGatta74", 9),  ("2022-02-24 9:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 18), ("2022-02-24 9:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 14),
       ("2022-02-24 12:30:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 8), ("2022-02-24 12:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 3),  ("2022-02-24 12:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 3),  ("2022-02-24 12:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 1),
       ("2022-02-24 13:10:00", null, "FrancescoVolpe70", 15), ("2022-02-24 13:14:00", "2022-02-22 23:59:59", "FlaviaGatta74", 13),  ("2022-02-24 13:42:00", null, "TommasoVolpe97", 18),  ("2022-02-24 13:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 21),
       ("2022-02-24 14:37:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 19),  ("2022-02-24 14:20:00", "2022-02-22 23:59:59", "FlaviaGatta74", 18), ("2022-02-24 14:15:00", "2022-02-22 23:59:59", "TommasoVolpe97", 12), ("2022-02-24 14:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 14),
       ("2022-02-24 21:31:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 21), ("2022-02-24 22:32:00", "2022-02-22 23:59:59", "FlaviaGatta74", 20),  ("2022-02-24 22:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 19), ("2022-02-24 22:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 17),
       ("2022-02-24 23:30:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 8), ("2022-02-24 23:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 2),  ("2022-02-24 23:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 21),  ("2022-02-24 23:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 13),

       ("2022-02-25 7:30:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 1), ("2022-02-25 8:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 4),  ("2022-02-25 7:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 6),  ("2022-02-25 8:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 8),
       ("2022-02-25 8:37:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 9),  ("2022-02-25 9:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 16), ("2022-02-25 9:15:00", "2022-02-22 23:59:59", "TommasoVolpe97", 11), ("2022-02-25 9:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 2),
       ("2022-02-25 9:31:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 4), ("2022-02-25 9:32:00", "2022-02-22 23:59:59", "FlaviaGatta74", 9),  ("2022-02-25 9:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 18), ("2022-02-25 9:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 14),
       ("2022-02-25 12:30:00", null, "FrancescoVolpe70", 8), ("2022-02-25 12:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 3),  ("2022-02-25 12:42:00", null, "TommasoVolpe97", 3),  ("2022-02-25 12:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 1),
       ("2022-02-25 13:10:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 15), ("2022-02-25 13:14:00", "2022-02-22 23:59:59", "FlaviaGatta74", 13),  ("2022-02-25 13:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 18),  ("2022-02-25 13:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 21),
       ("2022-02-25 14:37:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 19),  ("2022-02-25 14:20:00", "2022-02-22 23:59:59", "FlaviaGatta74", 18), ("2022-02-25 14:15:00", "2022-02-22 23:59:59", "TommasoVolpe97", 12), ("2022-02-25 14:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 14),
       ("2022-02-25 21:31:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 21), ("2022-02-25 22:32:00", "2022-02-22 23:59:59", "FlaviaGatta74", 20),  ("2022-02-25 22:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 19), ("2022-02-25 22:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 17),
       ("2022-02-25 23:30:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 8), ("2022-02-25 23:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 2),  ("2022-02-25 23:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 21),  ("2022-02-25 23:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 13),

       ("2022-02-26 7:30:00", "2022-02-22 21:09:31", "FrancescoVolpe70", 1), ("2022-02-26 8:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 4),  ("2022-02-26 7:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 6),  ("2022-02-26 8:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 8),
       ("2022-02-26 8:37:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 9),  ("2022-02-26 9:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 16), ("2022-02-26 9:15:00", "2022-02-22 23:59:59", "TommasoVolpe97", 11), ("2022-02-26 9:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 2),
       ("2022-02-26 9:31:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 4), ("2022-02-26 9:32:00", "2022-02-22 23:59:59", "FlaviaGatta74", 9),  ("2022-02-26 9:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 18), ("2022-02-26 9:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 14),
       ("2022-02-26 12:30:00", null, "FrancescoVolpe70", 8), ("2022-02-26 12:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 3),  ("2022-02-26 12:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 3),  ("2022-02-26 12:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 1),
       ("2022-02-26 13:10:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 15), ("2022-02-26 13:14:00", "2022-02-22 23:59:59", "FlaviaGatta74", 13),  ("2022-02-26 13:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 18),  ("2022-02-26 13:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 21),
       ("2022-02-26 14:37:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 19),  ("2022-02-26 14:20:00", "2022-02-22 23:59:59", "FlaviaGatta74", 18), ("2022-02-26 14:15:00", "2022-02-22 23:59:59", "TommasoVolpe97", 12), ("2022-02-26 14:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 14),
       ("2022-02-26 21:31:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 21), ("2022-02-26 22:32:00", "2022-02-22 23:59:59", "FlaviaGatta74", 20),  ("2022-02-26 22:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 19), ("2022-02-26 22:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 17),
       ("2022-02-26 23:30:00", "2022-02-22 23:59:59", "FrancescoVolpe70", 8), ("2022-02-26 23:10:00", "2022-02-22 23:59:59", "FlaviaGatta74", 2),  ("2022-02-26 23:42:00", "2022-02-22 23:59:59", "TommasoVolpe97", 21),  ("2022-02-26 23:30:00", "2022-02-22 23:59:59", "SofiaVolpe01", 13);

drop table if exists  Programma;
create table Programma (
	CodProgramma int auto_increment not null primary key,
    Dispositivo int not null,
    Durata int not null,
    Nome varchar(20) not null,
    Livello double not null
)engine = InnoDB default charset = latin1;  
    
insert into Programma (Dispositivo, Durata, Nome, Livello)
values (24, 30, "LavaggioBreve",0.500), (24, 45, "LavaggioMedioBreve",0.800), (24, 70, "LavaggioMedioLungo",1.000), (24, 90, "LavaggioLungo",1.200),
       (30, 40, "LavaggioBreve",0.600), (30, 50, "LavaggioMedioBreve",0.850), (30, 70, "LavaggioMedioLungo",1.000), (30, 90, "LavaggioLungo",1.200),
       (29, 20, "Livello1",0.300),      (29, 45, "Livello2",0.700),           (29, 60, "Livello3",0.900),           (29, 90, "Livello4",1.200),
       (22, 40, "Basso",0.600),         (22, 50, "Moderato",0.850),           (22, 70, "Alto",1.000),               (22, 90, "Altissimo",1.200),
	   (23, 40, "Basso",0.600),         (23, 50, "Moderato",0.850),           (23, 70, "Alto",1.000),               (23, 90, "Altissimo",1.200)
       ;

    
drop table if exists Potenza;
create table Potenza (
	CodPotenza int auto_increment not null,
    Livello double not null,
	Dispositivo int not null,
    primary key(CodPotenza, Dispositivo),
    foreign key (Dispositivo) references Dispositivo(CodDispositivo)
    on delete no action
    on update no action
    )engine = InnoDB default charset = latin1;
    
insert into Potenza (Livello, Dispositivo)
values (0.120,19), (0.110,20), (0.110,21), (0.140,22), (0.150,23), (0.130,24), (0.100,25), (0.120,26), (0.110,27), (0.130,28), (0.130,29), (0.150,30),
       (0.200,19), (0.210,20), (0.230,21), (0.180,22), (0.170,23), (0.170,24), (0.200,25), (0.220,26), (0.130,27), (0.170,28), (0.180,29), (0.230,30),
       (0.300,19), (0.250,20), (0.300,21), (0.250,22), (0.190,23), (0.230,24), (0.300,25), (0.320,26), (0.230,27), (0.230,28), (0.260,29), (0.300,30),
       (0.400,19), (0.350,20), (0.400,21), (0.350,22), (0.210,23), (0.300,24), (0.400,25), (0.420,26), (0.300,27), (0.320,28), (0.320,29), (0.450,30);

    
    
drop table if exists SmartPlug;    
create table SmartPlug(
	Codice int auto_increment not null primary key,
    Dispositivo int not null,
    Stanza int not null,
    foreign key (Dispositivo) references Dispositivo(CodDispositivo)
    on delete no action
    on update no action,
    foreign key (Stanza) references Stanza(CodStanza)
    on delete no action
    on update no action
    )engine = InnoDB default charset = latin1;
    
insert into SmartPlug (Dispositivo, Stanza)
values (1,1), (3,4), (7,6), (9,3), (2,3), (13,1), (15,8), (10,6), (6,7), (11,8), 
(18,2),(19,2),(20,2),(21,5),(22,5),(23,4),(24,4),(25,8),(26,4),(27,2),(28,9),(29,7),(30,7);

#---------------------------|
#		AREA COMFORT		|
#---------------------------|

drop table if exists Condizionamento;
create table Condizionamento(
	CodCondizionatore int not null,
	DataAvvio timestamp not null,
    Spegnimento date not null,
    LivelloUmidita double check (LivelloUmidita between 0 and 100),
    Temperatura double check (Temperatura between 16 and 30),
    primary key(DataAvvio, CodCondizionatore),
    foreign key (CodCondizionatore) references ElementodiCondizionamento(Codice)
    on delete no action
    on update no action
    )engine = InnoDB default charset = latin1;
    
insert into Condizionamento (CodCondizionatore, DataAvvio, Spegnimento, LivelloUmidita, Temperatura)
values (1, "2022-02-22 08:30:31", "2022-02-22 23:45:23", 48.6, 24.3), 
(4, "2022-02-22 10:30:31", "2022-02-22 21:45:23", 49.3, 24.5), 
(5, "2022-02-22 13:33:35", "2022-02-22 21:45:23", 47.6, 21), 
(6, "2022-02-23 15:20:23", "2022-02-23 20:46:23", 45.3, 24.1), 
(1, "2022-02-23 13:23:34", "2022-02-23 21:45:23", 48.6, 21), 
(7, "2022-02-22 13:38:31", "2022-02-22 23:45:23", 50.3, 25.3), 
(8, "2022-02-22 21:30:31", "2022-02-22 22:57:32", 53.2, 21), 
(2, "2022-02-22 09:30:31", "2022-02-22 22:45:23", 51.3, 22.3), 
(3, "2022-02-22 11:30:31", "2022-02-22 23:53:37", 56, 22.1), 
(5, "2022-02-23 14:33:35", "2022-02-23 21:45:23", 48, 21), 
(7, "2022-02-23 14:20:21", "2022-02-23 20:45:23", 52, 20), 
(4, "2022-02-23 12:23:34", "2022-02-22 19:47:34", 52.4, 24.3), 
(1, "2022-02-22 14:38:31", "2022-02-22 23:53:37", 48.6, 21), 
(3, "2022-02-22 22:30:31", "2022-02-22 23:53:37", 48.6, 24), 
(8, "2022-02-23 12:20:21", "2022-02-23 23:53:37", 49, 21), 
(7, "2022-02-24 17:23:34", "2022-02-24 23:53:37", 47.6, 21), 
(5, "2022-02-25 14:38:31", "2022-02-25 20:46:23", 51.6, 24.3), 
(2, "2022-02-23 22:30:31", "2022-02-23 23:53:37", 68.6, 24.3);
    

    

drop table if exists Schedulazione;
create table Schedulazione(
	Codice integer auto_increment not null,
    CodCondizionatore integer not null,
	DataAvvio timestamp not null,
	Giorno integer,
    Mese integer,
    primary key (Codice, DataAvvio, CodCondizionatore),
    foreign key (CodCondizionatore) references ElementodiCondizionamento(Codice),
    foreign key (DataAvvio) references Condizionamento(DataAvvio)
	)engine = InnoDB default charset = latin1;

insert into Schedulazione(CodCondizionatore, DataAvvio, Giorno, Mese)
values (3, "2022-02-22 22:30:31", 22, null),
	   (2, "2022-02-23 22:30:31", null, 02),
	   (6, "2022-02-23 15:20:23", 23, null),
       (7, "2022-02-22 13:38:31", null, 02),
       (4, "2022-02-22 10:30:31", 22, null);

drop table if exists ElementodiIlluminazione;
create table ElementodiIlluminazione(
	Codice int auto_increment not null primary key,
    Nome varchar(50), 
    Livello double,
    Stanza integer
	)engine = InnoDB default charset = latin1;

insert into ElementoDiIlluminazione(Nome, Livello, Stanza)
values ("Lampadario",0.113,1),
	   ("Lampadario",0.132,2),
       ("Lampadario",0.121,3),
       ("Lampadario",0.142,4),
       ("Lampadario",0.152,5),
       ("Lampadario",0.166,6),
       ("Lampadario",0.131,7),
       ("Lampadario",0.137,8),
       ("Lampadario",0.138,9),
	   ("Lampada",0.132,3),
       ("Lampada",0.127,8),
       ("Lampada",0.107,9),
       ("Abatjour",0.102,5),
       ("Abatjour",0.092,5),
       ("Abatjour",0.095,8),
       ("Abatjour",0.092,9),
       ("LuceSpecchio",0.083,4),
       ("LuceSpecchio",0.089,4),
       ("LuceSpecchio",0.091,7),
       ("LuceStudio",0.101,6);

drop table if exists ProprietaIlluminazione;
create table ProprietaIlluminazione(
	Temperatura varchar(10) not null,
    Intensita double not null,
    CodIlluminatore int not null,
    primary key(Temperatura, Intensita),
    foreign key (CodIlluminatore) references ElementodiIlluminazione(Codice)
	)engine = InnoDB default charset = latin1;

insert into ProprietaIlluminazione(Temperatura, Intensita, CodIlluminatore)
values ("028F73", 14.2, 1), ("04F18G", 13.2, 1), ("NDF92E", 35.3, 8), ("FFG438", 24, 1), ("D2518G", 21, 1),
("04G18G", 12.4, 6), ("24F225", 21.4, 1), ("048HFD", 12.7, 7), ("DGSD6G", 12.3, 1), ("6AV36G", 12.5, 1), ("3656HD", 32.8, 1), ("34RSFG", 23.2, 1), ("25FGDG", 35.4, 1), ("454Q29", 13.9, 1), ("EFSFS4", 25.8, 1), ("FFG4G6", 24, 2), ("6AV32G", 12.9, 2), ("EFFGS4", 25.2, 2), ("34RSFG", 23.0, 2), ("3456HD", 32.9, 2), ("254GDG", 35.2, 2), ("04816G", 13.0, 3),
("N3KG2E", 35.0, 3), ("FFF436", 24.1, 3), ("048FYD", 12.7, 2), ("048HYG", 12.7, 3), ("04G15G", 12.4, 3), ("454Q12", 13.9, 2), ("04816G", 13.2, 2), ("245G25", 21.4, 2), ("028H73", 14.2, 2), ("N3KK2E", 35.3, 2), ("DGFD0G", 12.3, 2),
("D2H16G", 21, 2), ("04G1FG", 12.4, 2), ("028FDF", 14.2, 3), ("245225", 21.4, 3), ("DGSD3G", 12.3, 3), ("245525", 21.4, 3), ("34H6HD", 32.8, 3), ("EFSGS4", 25.8, 3), ("34RHFG", 23.2, 3), ("454Q19", 13.9, 13), ("254GDG", 35.4, 3), ("D2G1KG", 21, 3), ("3456HD", 32.8, 4), ("N3K92E", 35.3, 4), ("028G73", 14.2, 4),
("FFG436", 24, 4), ("2452F5", 21.4, 4), ("048FDG", 13.2, 4), ("D2G16G", 21, 4), ("048H2G", 12.7, 4), ("6AV326G", 12.5, 4), ("DGSDLG", 12.3, 4), ("EFSFJ4", 25.8, 4), ("25HGDG", 35.4, 4), ("04G16G", 12.4, 4), ("34RAFG", 23.2, 4), ("454Q18", 13.9, 4), ("N3K9JE", 35.3, 5);

drop table if exists Luce;
create table Luce(
	CodIlluminatore int not null,
    DataInizio timestamp,
    Account varchar(20),
    Temperatura varchar(20),
    Intensita double,
    DataFine timestamp,
    primary key(CodIlluminatore, Datainizio),
    foreign key (CodIlluminatore) references ElementodiIlluminazione(Codice),
    foreign key (Account) references Account(Username)
    on delete no action
    on update no action,
    foreign key (Temperatura,Intensita) references ProprietaIlluminazione(Temperatura,Intensita)
	)engine = InnoDB default charset = latin1;
    
insert into Luce(CodIlluminatore, DataInizio, Account, Temperatura, Intensita, DataFine)
values (4, "2022-02-22 08:30:31", "FrancescoVolpe70", "FFG436", 24, null), 
(4, "2022-02-22 10:30:31", "FlaviaGatta74", "2452F5", 21.4, null), 
(5, "2022-02-22 13:33:35", "TommasoVolpe97", "N3K9JE", 35.3, "2022-02-22 23:33:35"), 
(6, "2022-02-22 15:20:21", "TommasoVolpe97", "04G18G", 12.4, null), 
(13, "2022-02-22 13:23:34", "TommasoVolpe97", "454Q19", 13.9, "2022-02-22 21:33:45"), 
(7, "2022-02-22 13:38:31", "SofiaVolpe01", "34RSFG", 23.2, null), 
(8, "2022-02-22 21:30:31", "SofiaVolpe01", "N3K92E", 35.3, "2022-02-22 22:34:35"); 





#-------------------------------------|
#		AREA SISTEMA DI CONTROLLO	  |
#-------------------------------------|

drop table if exists SistemadiControllo;
create table SistemadiControllo(
	Stanza int not null,
    CollegamentoEsterno int not null,
    DataEntrata date not null,
    Persona varchar (16),
    DataUscita date default null,
    primary key (Stanza, CollegamentoEsterno, DataEntrata, Persona),
    foreign key (Stanza) references Stanza(CodStanza)
    on delete no action
    on update no action,
    foreign key (CollegamentoEsterno) references CollegamentoEsterno(Codice)
    on delete no action
    on update no action
    )engine = InnoDB default charset = latin1;
    
insert into SistemadiControllo(Stanza, CollegamentoEsterno, DataEntrata, Persona, DataUscita)
values (1,1, "2022-02-21", "FrancescoVolpe70", "2022-02-21"),
(2,2, "2022-02-21", "TommasoVolpe97", "2022-02-21"),
(2,3, "2022-02-21", "SofiaVolpe01", "2022-02-21"),
(3,4, "2022-02-21", "FrancescoVolpe70", "2022-02-21"),
(9,14, "2022-02-21", "FrancescoVolpe70", null),
(2,3, "2022-02-20", "SofiaVolpe01", "2022-02-21"),
(3,4, "2022-02-21", "FlaviaGatta74", "2022-02-21"),
(9,14, "2022-02-21", "TommasoVolpe70", null);

drop table if exists Serramento;
create table Serramento(
	CollegamentoEsterno int not null,
    Nome varchar(20) not null,
    Tapertura date not null,
    Tchiusura date default null,
    primary key (CollegamentoEsterno),
    foreign key (CollegamentoEsterno) references CollegamentoEsterno(Codice)
    on delete no action
    on update no action
	) engine = InnoDB default charset = latin1;
    
insert into Serramento(CollegamentoEsterno, Nome, Tapertura, Tchiusura)
values (1,"Persiane","2022-02-22 08:46:21","2022-02-22 18:46:21"), (2,"Persiane","2022-02-22 08:46:21","2022-02-22 19:46:21"), (3,"Tapparelle","2022-02-22 08:46:21","2022-02-22 21:46:21"), 
(4,"Tapparelle","2022-02-22 08:46:21","2022-02-22 22:46:21"), (5,"Persiane","2022-02-22 08:46:21","2022-02-22 19:46:21"), 
       (6,"Persiane","2022-02-22 08:46:21","2022-02-22 16:46:21"), (7,"Tapparelle","2022-02-22 08:46:21","2022-02-22 23:46:21"), (8,"Tapparelle","2022-02-22 08:46:21","2022-02-22 21:46:21"), 
       (9,"Tapparelle","2022-02-22 08:46:21","2022-02-22 21:46:21"), (10,"Persiane","2022-02-22 08:46:21","2022-02-22 23:46:21"),
       (11,"Tapparelle","2022-02-22 08:46:21","2022-02-22 23:46:21"), (12,"Tapparelle","2022-02-22 08:46:21","2022-02-22 23:46:21"), (13,"Persiane","2022-02-22 08:46:21","2022-02-22 22:46:21"),
       (14,"Tapparelle","2022-02-22 08:46:21","2022-02-22 22:46:21"), (15,"Tapparelle","2022-02-22 08:46:21","2022-02-22 23:46:21");

#---------------------------|
#		 AREA ENERGIA		|
#---------------------------|


drop table if exists PannelliSolari;
create table PannelliSolari(
	Codice int auto_increment not null primary key
    )engine = InnoDB default charset = latin1;
  
insert into PannelliSolari values (null),(null),(null),(null),(null),(null); 

drop table if exists Produzione;  
create table Produzione(
    Timestamp timestamp,
	Livello double check (Livello>=0),
	CodPannello int not null,
	primary key(Timestamp, CodPannello),
	foreign key (CodPannello) references PannelliSolari(Codice)
    on delete no action
    on update no action
    )engine = InnoDB default charset = latin1;

insert into Produzione (Timestamp, Livello, CodPannello)
values 
 ("2022-02-22 00:00",0,1), ("2022-02-22 00:10",0,1), ("2022-02-22 00:20",0,1), ("2022-02-22 00:30",0,1), ("2022-02-22 00:40",0,1), ("2022-02-22 00:50",0,1), ("2022-02-22 01:00",0,1), ("2022-02-22 01:10",0,1), ("2022-02-22 01:20",0,1), ("2022-02-22 01:30",0,1), ("2022-02-22 01:40",0,1),
("2022-02-22 01:50",0,1), ("2022-02-22 02:00",0,1), ("2022-02-22 02:10",0,1), ("2022-02-22 02:20",0,1), ("2022-02-22 02:30",0,1), ("2022-02-22 02:40",0,1), ("2022-02-22 02:50",0,1), ("2022-02-22 03:00",0,1), ("2022-02-22 03:10",0,1), ("2022-02-22 03:20",0,1), ("2022-02-22 03:30",0,1), ("2022-02-22 03:40",0,1),
("2022-02-22 03:50",0,1), ("2022-02-22 04:00",0,1), ("2022-02-22 04:10",0,1), ("2022-02-22 04:20",0,1), ("2022-02-22 04:30",0,1), ("2022-02-22 04:40",0,1), ("2022-02-22 04:50",0,1), ("2022-02-22 05:00",0,1), ("2022-02-22 05:10",0,1), ("2022-02-22 05:20",0,1), ("2022-02-22 05:30",1.2,1), ("2022-02-22 05:40",1.2,1), ("2022-02-22 05:50",1.2,1), ("2022-02-22 06:00",1.2,1), ("2022-02-22 06:10",1.2,1), ("2022-02-22 06:20",1.2,1), ("2022-02-22 06:30",2.3,1), ("2022-02-22 06:40",2.3,1), ("2022-02-22 06:50",2.3,1), ("2022-02-22 07:00",2.3,1), ("2022-02-22 07:10",2.3,1), ("2022-02-22 07:20",2.3,1), ("2022-02-22 07:30",3.2,1), ("2022-02-22 07:40",3.2,1), ("2022-02-22 07:50",3.2,1), ("2022-02-22 08:00",3.2,1), ("2022-02-22 08:10",3.2,1),
("2022-02-22 08:20",3.2,1), ("2022-02-22 08:30",4.3,1), ("2022-02-22 08:40",4.3,1), ("2022-02-22 08:50",4.3,1), ("2022-02-22 09:00",4.3,1), ("2022-02-22 09:10",4.3,1), ("2022-02-22 09:20",4.3,1), ("2022-02-22 09:30",5.1,1), ("2022-02-22 09:40",5.1,1), ("2022-02-22 09:50",5.1,1),
("2022-02-22 10:00",5.1,1), ("2022-02-22 10:10",5.1,1), ("2022-02-22 10:20",5.1,1), ("2022-02-22 10:30",6,1), ("2022-02-22 10:40",6,1), ("2022-02-22 10:50",6,1), ("2022-02-22 11:00",6,1), ("2022-02-22 11:10",6,1), ("2022-02-22 11:20",6,1), ("2022-02-22 11:30",7.2,1), ("2022-02-22 11:40",7.2,1), ("2022-02-22 11:50",7.2,1), ("2022-02-22 12:00",7.2,1), ("2022-02-22 12:10",7.2,1), ("2022-02-22 12:20",7.2,1), ("2022-02-22 12:30",7,1), ("2022-02-22 12:40",7,1), ("2022-02-22 12:50",7,1), ("2022-02-22 13:00",7,1), ("2022-02-22 13:10",7,1), ("2022-02-22 13:20",7,1), ("2022-02-22 13:30",6.9,1), ("2022-02-22 13:40",6.9,1), ("2022-02-22 13:50",6.9,1), ("2022-02-22 14:00",6.9,1), ("2022-02-22 14:10",6.9,1), ("2022-02-22 14:20",6.3,1), 
("2022-02-22 14:30",6.3,1), ("2022-02-22 14:40",6.3,1), ("2022-02-22 14:50",6.3,1), ("2022-02-22 15:00",6.3,1), ("2022-02-22 15:10",6.1,1), ("2022-02-22 15:20",6.1,1), ("2022-02-22 15:30",6.1,1), ("2022-02-22 15:40",6.1,1), ("2022-02-22 15:50",6.1,1), ("2022-02-22 16:00",5.4,1), ("2022-02-22 16:10",5.4,1), ("2022-02-22 16:20",5.4,1), ("2022-02-22 16:30",5.4,1), ("2022-02-22 16:40",5.4,1), ("2022-02-22 16:50",5.2,1), ("2022-02-22 17:00",5.2,1), ("2022-02-22 17:10",5.2,1),
("2022-02-22 17:20",4.1,1), ("2022-02-22 17:30",3.2,1), ("2022-02-22 17:40",1.8,1), ("2022-02-22 17:50",1.1,1), ("2022-02-22 18:00",0,1), ("2022-02-22 18:10",0,1), ("2022-02-22 18:20",0,1), ("2022-02-22 18:30",0,1), ("2022-02-22 18:40",0,1), ("2022-02-22 18:50",0,1), ("2022-02-22 19:00",0,1), ("2022-02-22 19:10",0,1), ("2022-02-22 19:20",0,1), ("2022-02-22 19:30",0,1), ("2022-02-22 19:40",0,1), ("2022-02-22 19:50",0,1), ("2022-02-22 20:00",0,1), ("2022-02-22 20:10",0,1), ("2022-02-22 20:20",0,1), ("2022-02-22 20:30",0,1), ("2022-02-22 20:40",0,1), ("2022-02-22 20:50",0,1), ("2022-02-22 21:00",0,1),
("2022-02-22 21:10",0,1), ("2022-02-22 21:20",0,1), ("2022-02-22 21:30",0,1), ("2022-02-22 21:40",0,1), ("2022-02-22 21:50",0,1), ("2022-02-22 22:00",0,1), ("2022-02-22 22:10",0,1), ("2022-02-22 22:20",0,1), ("2022-02-22 22:30",0,1), ("2022-02-22 22:40",0,1), ("2022-02-22 22:50",0,1), ("2022-02-22 23:00",0,1), ("2022-02-22 23:10",0,1), ("2022-02-22 23:20",0,1), ("2022-02-22 23:30",0,1), ("2022-02-22 23:40",0,1), ("2022-02-22 23:50",0,1);


drop table if exists Utilizzo;
create table Utilizzo(
	Timestamp timestamp,
    FasciaTariffaria int not null,
    primary key(Timestamp)
    )engine = InnoDB default charset = latin1;
    
insert into Utilizzo (Timestamp, FasciaTariffaria)
values  ("2022-02-22 00:00", 1), ("2022-02-22 00:10", 1), ("2022-02-22 00:20", 1), ("2022-02-22 00:30", 1), ("2022-02-22 00:40", 1), ("2022-02-22 00:50", 1), ("2022-02-22 01:00", 1), ("2022-02-22 01:10", 1), ("2022-02-22 01:20", 1), ("2022-02-22 01:30", 1), ("2022-02-22 01:40", 1),
("2022-02-22 01:50", 1), ("2022-02-22 02:00", 1), ("2022-02-22 02:10", 1), ("2022-02-22 02:20", 1), ("2022-02-22 02:30", 1), ("2022-02-22 02:40", 1), ("2022-02-22 02:50", 1), ("2022-02-22 03:00", 1), ("2022-02-22 03:10", 1), ("2022-02-22 03:20", 1), ("2022-02-22 03:30", 1), ("2022-02-22 03:40", 1),
("2022-02-22 03:50", 1), ("2022-02-22 04:00", 1), ("2022-02-22 04:10", 1), ("2022-02-22 04:20", 1), ("2022-02-22 04:30", 1), ("2022-02-22 04:40", 1), ("2022-02-22 04:50", 1), ("2022-02-22 05:00", 1), ("2022-02-22 05:10", 1), ("2022-02-22 05:20", 1), ("2022-02-22 05:30", 1), ("2022-02-22 05:40", 1), ("2022-02-22 05:50", 1), ("2022-02-22 06:00", 1), ("2022-02-22 06:10", 1), ("2022-02-22 06:20", 1), ("2022-02-22 06:30", 1), ("2022-02-22 06:40", 1), ("2022-02-22 06:50", 1), ("2022-02-22 07:00",2), ("2022-02-22 07:10",2), ("2022-02-22 07:20",2), ("2022-02-22 07:30",2), ("2022-02-22 07:40",2), ("2022-02-22 07:50",2), ("2022-02-22 08:00",2), ("2022-02-22 08:10",2),
("2022-02-22 08:20",2), ("2022-02-22 08:30", 2), ("2022-02-22 08:40", 2), ("2022-02-22 08:50", 2), ("2022-02-22 09:00", 2), ("2022-02-22 09:10", 2), ("2022-02-22 09:20", 2), ("2022-02-22 09:30", 2), ("2022-02-22 09:40", 2), ("2022-02-22 09:50", 2),
("2022-02-22 10:00", 2), ("2022-02-22 10:10", 2), ("2022-02-22 10:20", 2), ("2022-02-22 10:30", 2), ("2022-02-22 10:40", 2), ("2022-02-22 10:50", 2), ("2022-02-22 11:00", 2), ("2022-02-22 11:10", 2), ("2022-02-22 11:20", 2), ("2022-02-22 11:30",2), ("2022-02-22 11:40",2), ("2022-02-22 11:50",2), ("2022-02-22 12:00",2), ("2022-02-22 12:10",2), ("2022-02-22 12:20",2), ("2022-02-22 12:30",2), ("2022-02-22 12:40",2), ("2022-02-22 12:50",2), ("2022-02-22 13:00",3), ("2022-02-22 13:10",3), ("2022-02-22 13:20",3), ("2022-02-22 13:30",3), ("2022-02-22 13:40",3), ("2022-02-22 13:50",3), ("2022-02-22 14:00",3), ("2022-02-22 14:10",3), ("2022-02-22 14:20", 3), 
("2022-02-22 14:30", 3), ("2022-02-22 14:40", 3), ("2022-02-22 14:50", 3), ("2022-02-22 15:00", 3), ("2022-02-22 15:10", 3), ("2022-02-22 15:20", 3), ("2022-02-22 15:30", 3), ("2022-02-22 15:40", 3), ("2022-02-22 15:50", 3), ("2022-02-22 16:00", 3), ("2022-02-22 16:10", 3), ("2022-02-22 16:20", 3), ("2022-02-22 16:30", 3), ("2022-02-22 16:40", 3), ("2022-02-22 16:50", 3), ("2022-02-22 17:00", 3), ("2022-02-22 17:10", 3),
("2022-02-22 17:20",3), ("2022-02-22 17:30",3), ("2022-02-22 17:40",3), ("2022-02-22 17:50", 3), ("2022-02-22 18:00", 1), ("2022-02-22 18:10", 3), ("2022-02-22 18:20", 3), ("2022-02-22 18:30", 3), ("2022-02-22 18:40", 3), ("2022-02-22 18:50", 3), ("2022-02-22 19:00", 3), ("2022-02-22 19:10", 3), ("2022-02-22 19:20", 3), ("2022-02-22 19:30", 3), ("2022-02-22 19:40", 3), ("2022-02-22 19:50", 3), ("2022-02-22 20:00", 3), ("2022-02-22 20:10", 3), ("2022-02-22 20:20", 3), ("2022-02-22 20:30", 3), ("2022-02-22 20:40", 3), ("2022-02-22 20:50", 3), ("2022-02-22 21:00", 3),
("2022-02-22 21:10", 1), ("2022-02-22 21:20", 3), ("2022-02-22 21:30", 3), ("2022-02-22 21:40", 3), ("2022-02-22 21:50", 1), ("2022-02-22 22:00", 3), ("2022-02-22 22:10", 3), ("2022-02-22 22:20", 3), ("2022-02-22 22:30", 3), ("2022-02-22 22:40", 3), ("2022-02-22 22:50", 3), ("2022-02-22 23:00", 3), ("2022-02-22 23:10", 3), ("2022-02-22 23:20", 3), ("2022-02-22 23:30", 3), ("2022-02-22 23:40", 3), ("2022-02-22 23:50", 3);

    
drop table if exists FasciaTariffaria;
create table FasciaTariffaria(
	Codice int auto_increment not null primary key,
    Costo double not null,
    RangeF int not null check (RangeF=7 or RangeF=15 or RangeF=23)
    )engine = InnoDB default charset = latin1;
    
insert into FasciaTariffaria (Costo, RangeF)
values (6, 7), (20, 15), (15, 23);


drop table if exists Batteria;
create table Batteria(
	CodBatteria int auto_increment not null primary key,
	Capienza double check (Capienza between 40 and 100)
	)engine = InnoDB default charset = latin1;
        
insert into Batteria (Capienza)
values (46), (60), (76), (89), (66), (75), (72), (91);
        
drop table if exists Stoccaggio;
create table Stoccaggio(
	CodBatteria int not null,
	Timestamp timestamp,
	primary key (CodBatteria, Timestamp),
	foreign key (CodBatteria) references Batteria(CodBatteria)
    on delete no action
    on update no action
	)engine = InnoDB default charset = latin1;
    
insert into Stoccaggio (CodBatteria, Timestamp)
values (1,"2022-02-22 04:00:00"),
	   (1,"2022-02-23 04:00:00"),
       (1,"2022-02-24 04:00:00"),
       (1,"2022-02-25 04:00:00"),
       (1,"2022-02-26 04:00:00"),
       (1,"2022-02-27 04:00:00"),
       (1,"2022-02-28 04:00:00")
    ;
        
        
drop table if exists ReteElettrica;
create table ReteElettrica(
	CodReteElettrica double not null primary key
    )engine = InnoDB default charset = latin1;

insert into ReteElettrica (CodReteElettrica)
values (639591688484);
    
drop table if exists Immissione;
create table Immissione(
	CodReteElettrica double not null,
    TimeStamp timestamp,
    DataImmissione date,
    primary key (CodReteElettrica, Timestamp),
    foreign key (CodReteElettrica) references ReteElettrica(CodReteElettrica)
    on delete no action
    on update no action
    )engine = InnoDB default charset = latin1;
    
insert into Immissione (CodReteElettrica, Timestamp)
values (639591688484,"2022-02-01 00:00:00"),
       (639591688484,"2022-03-01 00:00:00"),
       (639591688484,"2022-04-01 00:00:00"),
       (639591688484,"2022-05-01 00:00:00"),
       (639591688484,"2022-06-01 00:00:00"),
       (639591688484,"2022-07-01 00:00:00");
    
drop table if exists Suggerimento;
create table Suggerimento(
	CodiceSuggerimento int auto_increment not null primary key,
	Data date not null,
    Account varchar (50),
    Programma int not null,
    SceltaUtente int not null,
    foreign key (Account) references Account(Username)
    on delete no action
    on update no action,
    foreign key (Programma) references Programma(CodProgramma)
    on delete no action
    on update no action
	)engine = InnoDB default charset = latin1;