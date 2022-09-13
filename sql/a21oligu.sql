/* Init database */
drop database if exists a21oligu;
create database a21oligu;
use a21oligu;

/* 
Tomtens renar identifieras av deras rennummer (11 siffrors löpnummer) eller deras namn som i
sin tur består av renens klan-namn och underart (underarten kan vara någon av pearyi / tarandus /
buskensis / caboti / dawsoni / sibericus). Renarna har ett värde som beskriver renens stank som
anges i fem steg från “tolererbar” till “så man svimmar”. En ren kan även ha vunnit ett antal
priser som tomten delar ut varje år. Varje pris består av en titel och ett årtal exv “Snabbaste
2016” eller “Värsta stanken 2019”. För varje ren ska det gå att beräkna vilka regioner renen
tjänstgjort i.
Det finns två typer av renar, tjänste-renar och pensionerade renar. För att nissen som
administrerar slädarna ska veta om renarna fungerar tillsammans, så lagras vilka renar som den
tidigare arbetat tillsammans med. En ren måste delta i exakt ett renspann men ett renspann kan
ha noll eller flera renar. En ren administreras av noll eller flera mellanchefer.

Tjänsteren: En ren som är i tjänst har en lön som sätts in på ett numrerat bankkonto.

Pensionerad ren: När en ren “pensioneras” skickas den omedelbart till pölsa-fabriken för att
direkt omsättas till pölsa. Serienumret för pölsa-burkarna som renen hamnar i lagras i systemet
som ett värde exv 307.2461-307.2467. Utöver detta lagras namnet på pölsa-fabriken och
smaksättningen på pölsan (exv “Extra Kryddpeppar” eller “Utan Mejram”). När en ren
pensioneras så ska databasen ej förändras i övrigt (för att bibehålla historiken). Dock ska det av
förklarliga orsaker inte vara möjligt att boka ett renspann om någon av renarna är pensionerad.
Oftast pensionerar administratörer eller mellanchefer hela renspann på en gång för att undvika att
det blir problem med redan genomförda bokningar eller problem med att göra nya bokningar.

*/

/* TABELLER */
CREATE TABLE Spann (
	namn varchar(32),
    kapacitet smallint unsigned NOT NULL,
    primary key (namn)
)ENGINE=INNODB;

/* Inheritance using alt. C */
CREATE TABLE Ren (
	nr smallint,
    klan varchar(32), 
    underart varchar(10),
    stank tinyint unsigned NOT NULL,
    spann varchar(32),
    
    /* tjänste-ren*/
    lön real,
    
    /* pensionerad ren */
    pölseburknr char(17), /* Antagande: alla burknr följer samma format som i exempel, varav char(17) */
    fabriknamn varchar(32),
    smak varchar(32),
    
    /* typ som indentifierar typ av ren (pensionerad/tjänste ren) */
    typ varchar(16),
    
    check (underart IN ("pearyi", "tarandus", "buskensis", "caboti", "dawsoni", "sibericus")), /* limitera underart till specifierade värden */
    primary key (nr, klan, underart),
    foreign key (spann) references Spann(namn)
)ENGINE=INNODB;

CREATE TABLE Mat (
	namn varchar(32),
    tillverkare varchar(32),
    maginivå smallint,
    primary key (namn)
)ENGINE=INNODB;

CREATE TABLE MatSmak ( /* egen tabell för smak då den kan va stor, 1-1 */
	namn varchar(32),
    smak varchar(255),
    primary key (namn)
)ENGINE=INNODB;

/* RELATIONER */
CREATE TABLE RenÄterMat (
	mat varchar(32),
    nr smallint,
    klan varchar(32),
    underart varchar(10),
    check (mat != "pölse"),
    primary key (mat, nr, klan, underart),
    foreign key (nr, klan, underart) references Ren(nr, klan, underart)
)ENGINE=INNODB;

CREATE TABLE JobbatMed (
	ren1_nr smallint,
    ren1_klan varchar(32),
    ren1_underart varchar(10),
    
    ren2_nr smallint,
    ren2_klan varchar(32),
    ren2_underart varchar(10),
    
    primary key (ren1_nr, ren1_klan, ren1_underart, ren2_nr, ren2_klan, ren2_underart),
    foreign key (ren1_nr, ren1_klan, ren1_underart) references Ren(nr, klan, underart),
    foreign key (ren2_nr, ren2_klan, ren2_underart) references Ren(nr, klan, underart)
)ENGINE=INNODB;

/* MULTIVÄRDA ATTRIBUT */
CREATE TABLE RenPris (
	nr smallint,
    klan varchar(32),
    underart varchar(10),
    titel varchar(32),
    årtal smallint unsigned NOT NULL,
    PRIMARY KEY (nr, klan, underart, titel, årtal),
    FOREIGN KEY (nr, klan, underart) REFERENCES Ren(nr, klan, underart)
)ENGINE=INNODB;

/* TESTNING AV TABELLER */
INSERT INTO Spann VALUES ("spann1", 20);
INSERT INTO Ren values (0, "klan1", "buskensis", "skit", "spann1");
INSERT INTO Ren values (0, "klan1", "fails", "skit", "spann1"); /* SHOULD FAIL */
INSERT INTO Mat VALUES ("Falukorv", "körv", "scan", 200);
INSERT INTO Mat VALUES ("Pölse", "körv", "scan", 200);
INSERT INTO RenÄterMat VALUES ("Falukorv", 0, "buskensis", "kung");
INSERT INTO RenÄterMat VALUES ("Pölse", 0, "buskensis", "kung"); /* SHOULD FAIL */