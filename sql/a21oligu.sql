/* Init database */
drop database if exists a21oligu;
create database a21oligu;
use a21oligu;

/*CREATE USER "admin"@"%" IDENTIFIED BY "password";*/
CREATE USER IF NOT EXISTS "tomtefar"@"%" IDENTIFIED BY "tomten";
CREATE USER IF NOT EXISTS "admin"@"%" IDENTIFIED BY "admin";

# Ge användaren tomtefar alla privilegier
GRANT ALL PRIVILEGES ON a21oligu.* TO "tomtefar"@"%";

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

/* LOGG TABELLER */

# Tabell för att logga händelser i Spann tabellen.
CREATE TABLE SpannLogg (
	operation VARCHAR(16),
	användare varchar(32),
    spann VARCHAR(32),
    tid TIMESTAMP
)ENGINE=INNODB;

/* TABELLER */
CREATE TABLE Spann (
	namn varchar(32),
    kapacitet smallint unsigned NOT NULL,
    primary key (namn)
)ENGINE=INNODB;

CREATE TABLE Fabrik (
	id int,
	namn varchar(32),
    primary key (id)
)ENGINE=INNODB;

CREATE TABLE Stank (
	id tinyint unsigned,
    namn varchar(32),
    primary key (id)
)ENGINE=INNODB;

CREATE TABLE Tillverkare (
	id smallint,
    namn varchar(32),
    primary key (id)
)ENGINE=INNODB;

/* Inheritance using alt. C */
CREATE TABLE Ren (
	nr char(11),
    klan varchar(32) NOT NULL, 
    underart varchar(10) NOT NULL,
    stank tinyint unsigned NOT NULL,
    spann varchar(32),
    
    /* tjänste-ren*/
    lön real,
    
    /* pensionerad ren */
    pölseburknr char(17), /* Antagande: alla burknr följer samma format som i exempel, varav char(17) */
    fabrik int, /* int som pekar på id i tabell Fabrik */
    smak varchar(32),
    
    /* typ som indentifierar typ av ren (pensionerad/tjänste) */
    typ varchar(16),
    
    check (underart IN ("pearyi", "tarandus", "buskensis", "caboti", "dawsoni", "sibericus")), /* limitera underart till specifierade värden */
    primary key (nr),
    foreign key (stank) references Stank(id),
    foreign key (spann) references Spann(namn),
    foreign key (fabrik) references Fabrik(id),
    
    # Index på namn (klan + underart)
    INDEX namn (klan, underart)
)ENGINE=INNODB;

CREATE TABLE Mat (
	namn varchar(32),
    tillverkare smallint,
    maginivå smallint,
    primary key (namn),
    foreign key (tillverkare) references Tillverkare(id)
)ENGINE=INNODB;

CREATE TABLE MatSmak ( /* egen tabell för smak då den också kan vara en beskrivning, 1-1 */
	namn varchar(32),
    smak varchar(255),
    primary key (namn),
    foreign key (namn) references Mat(namn)
)ENGINE=INNODB;

/* RELATIONER */
CREATE TABLE RenÄterMat (
	mat varchar(32),
    nr char(11),
    check (mat != "pölse"),
    primary key (mat, nr),
    foreign key (nr) references Ren(nr)
)ENGINE=INNODB;

CREATE TABLE JobbatMed (
	ren1_nr char(11),
    ren2_nr char(11),
    
    primary key (ren1_nr, ren2_nr),
    foreign key (ren1_nr) references Ren(nr),
    foreign key (ren2_nr) references Ren(nr)
)ENGINE=INNODB;

/* MULTIVÄRDA ATTRIBUT */
CREATE TABLE RenPris (
	nr char(11),
    titel varchar(32),
    årtal smallint unsigned NOT NULL,
    PRIMARY KEY (nr, titel, årtal),
    FOREIGN KEY (nr) REFERENCES Ren(nr)
)ENGINE=INNODB;

/* VIEWS */

# Hämtar antal renar i ett givet spann
CREATE VIEW AntalRenarISpann AS 
SELECT COUNT(*) AS antal, Ren.spann
FROM Ren
GROUP BY Ren.spann;

# Hämtar andel av kapacitet som är upptagen i ett spann
CREATE VIEW AndelAvKapacitetISpann AS 
SELECT Spann.namn as spann, AntalRenarISpann.antal / Spann.kapacitet as andel
FROM AntalRenarISpann, Spann
WHERE AntalRenarISpann.spann = Spann.namn;

/* PROCEDURES */
DELIMITER &&

# Räkna ut antal renar i ett spann
CREATE PROCEDURE RenarISpann(spann VARCHAR(32))
BEGIN
	SELECT *
    FROM Ren
    WHERE Ren.spann = spann;
END &&

CREATE PROCEDURE PensioneraRen(
nr char(11), 
burknr char(17), 
fabrik smallint unsigned,
smak varchar(255))
BEGIN

	/*IF (USER() != "tomtefar@%") THEN
		SET @message = CONCAT("Permission denied for [", USER(), "]");
		SIGNAL SQLSTATE "45001" set message_text = @message;
    END IF;*/
    
    DECLARE typ varchar(32) DEFAULT "none";
    
    # Hämta typ för vald ren
    SELECT Ren.typ INTO typ FROM Ren WHERE Ren.nr = nr;
    
    IF (typ = "none" ) THEN
		SET @message = CONCAT("No ren with nr ", nr);
        SIGNAL SQLSTATE "45000" set message_text = @message;
    END IF;
		
	# Guard som kollar att vald ren inte redan är pensionerad
    IF (typ != "tjänste") THEN
		SET @message = CONCAT("Ren with löpnummer ", nr, " has already retired");
		SIGNAL SQLSTATE "45000" set message_text = @message;
    END IF;

	# Uppdatera värden för den nypensionerade renen, behåll oberörd data
	UPDATE Ren 
    SET Ren.pölseburknr = burknr, Ren.fabrik = fabrik, Ren.smak = smak, Ren.typ = "pensionerad"
    WHERE Ren.nr = nr;
    
END &&

/* TRIGGERS */
#Kollar om ett spanns kapacitet är uppnåd innan en insert (rule checking)
CREATE TRIGGER SpannKapacitetCheck BEFORE INSERT ON Ren 
FOR EACH ROW 
BEGIN
	DECLARE percentage REAL;
    
    SELECT andel 
    INTO percentage
    FROM AndelAvKapacitetISpann
    WHERE AndelAvKapacitetISpann.spann = NEW.spann;
    
	IF percentage >= 1 THEN
		SET @message = concat(NEW.spann, " has reached its maximum capacity");
		SIGNAL SQLSTATE "45000" set message_text = @message;
    END IF;
END &&

# Logga vid insert av spann
CREATE TRIGGER SpannInsertLogg AFTER INSERT ON Spann
FOR EACH ROW
BEGIN
	INSERT INTO SpannLogg VALUES ("INSERT", USER(), NEW.namn, CURRENT_TIMESTAMP());
END &&

DELIMITER ;

/* INDEXES */

/* TESTNING AV TABELLER */
INSERT INTO Tillverkare VALUES (0, "Scan");
INSERT INTO Fabrik VALUES (0, "Tomtens slakteri");

INSERT INTO Stank VALUES (5, "Skit");

INSERT INTO Spann VALUES ("spann1", 3);
INSERT INTO Spann VALUES ("spann2", 1);

INSERT INTO Ren(nr, klan, underart, stank, spann, lön, typ) values ("11111111111", "klan1", "buskensis", 5, "spann1", 2000, "tjänste");

/* INSERT INTO Ren values (0, "klan1", "fails", "skit", "spann1"); /* SHOULD FAIL */
INSERT INTO Mat VALUES ("Falukorv", 0, 3);
INSERT INTO Mat VALUES ("Pölse", 0, 1337);
INSERT INTO RenÄterMat VALUES ("Falukorv", "11111111111");
/* INSERT INTO RenÄterMat VALUES ("Pölse", 0, "buskensis", "kung"); /* SHOULD FAIL */

INSERT INTO Ren(nr, klan, underart, stank, spann, lön, typ) values ("11111111112", "klan1", "buskensis", 5, "spann1", 2000, "tjänste");
INSERT INTO Ren(nr, klan, underart, stank, spann, lön, typ) values ("11111111113", "klan1", "buskensis", 5, "spann2", 2000, "tjänste");
INSERT INTO Ren(nr, klan, underart, stank, spann, lön, typ) values ("11111111114", "klan1", "buskensis", 5, "spann1", 2000, "tjänste");

SELECT * FROM AntalRenarISpann;

SELECT * FROM AndelAvKapacitetISpann WHERE spann = "spann2";

SELECT * FROM SpannLogg;

CALL RenarISpann("spann1");
CALL RenarISpann("spann1");

CALL PensioneraRen("11111111111", "307.2461-307.2467", 0, "Tvärgo korv");
# CALL PensioneraRen("11111111111", "307.2461-307.2467", 0, "Tvärgo korv"); /* SHOULD FAIL */

SELECT * FROM Ren;