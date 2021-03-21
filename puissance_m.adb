with text_io; use text_io;
with ada.float_text_io; use ada.float_text_io;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

-- Amine Charifi, Groupe C
-- TP Bilan: Puissance M

procedure puissance_m is

M_MIN:constant integer:=4;	--Taille min d'un alignement de jetons
N_MAX:constant integer:=10;	--Taille max de la grille de jeu
type SYMBOLE is (LIBRE,BLEU,ROUGE);	--Contenu d'une case de la grille
type GRILLE is array(1..N_MAX,1..N_MAX) of SYMBOLE;	--Une grille
type JOUEUR is (JBLEU,JROUGE);		--Deux joueurs seulement
type ETAT_JEU is (EN_COURS,GAGNE,NUL);	

--Procedure:initialiser_jeu
--Initialise la grille de jeu et le premier joueur
--Parametres: Fla_grille:(D/R), GRILLE, la grille de jeu
--	      Fle_n: (R), entier, dimension reelle de la grille
--	      Fle_m: (R), entier, taille min d'un alignement
--	      Fl_etat: (R), ETAT_JEU, l'etat du jeu
--	      Fle_joueur: (R), JOUEUR, le joueur qui joue en premier
--Preconditions:_
--Postconditions: Toutes les cases de la grille contiennent LIBRE
--                M_MIN<=Fle_n<=N_MAX
--                M_MIN<=Fle_m<=Fle_n
--                Fl_etat=EN_COURS
--                Fle_joueur=JBLEU || Fle_joueur=JROUGE
--Exceptions:_

procedure initialiser_jeu(Fla_grille:in out GRILLE;Fle_n:out integer;Fle_m:out integer;Fl_etat:out ETAT_JEU;Fle_joueur:out JOUEUR) is
aux_le_n:integer;	--pour consulter la dimension reelle de la grille
aux_le_m:integer;	--pour consulter la taille min d'un alignement
choix_joueur:character;	--pour le choix du premier joueur
begin
  --Lire la dim reelle de la grille de maniere fiable et conviviale
  loop
    put_line("Choisissez la dimension de la grille:");
    get(aux_le_n);
    new_line;
    exit when (M_MIN<=aux_le_n and aux_le_n<=N_MAX);
  end loop;
  -- M_MIN<= aux_le_n <=N_MAX

  --Lire la taille min d'un alignement de manière fiable et conviviale
  loop
    put_line("Choisissez la taille min d'un alignement:");
    get(aux_le_m);
    new_line;
    exit when (M_MIN<=aux_le_m and aux_le_m<=aux_le_n);
  end loop;
  -- M_MIN<= aux_le_m <=aux_le_n

  --Initialiser toutes les cases de la grille à LIBRE
  for i in 1..aux_le_n loop
    for j in 1..aux_le_n loop
      Fla_grille(i,j):=LIBRE;
    end loop;
  end loop;

  --l'etat du jeu est en cours
  Fl_etat:=EN_COURS;

  --Affectation de la dim reelle et la taille min d'alignement
  Fle_n:=aux_le_n;
  Fle_m:=aux_le_m;

  --Choisir le premier joueur
  loop
    put_line("Qui joue en premier? (b=BLEU, r=ROUGE)");
    get(choix_joueur);
    new_line;
    exit when (choix_joueur='b' or choix_joueur='r');
  end loop;
  --choix du joueur valide: choix_joueur='b' ou choix_joueur='r'
  if choix_joueur='b' then
    Fle_joueur:=JBLEU;
  else
    Fle_joueur:=JROUGE;
  end if;
end initialiser_jeu;


--Procedure: afficher_jeu
--Afficher la grille et le joueur courant
--Parametres: Fla_grille:(D), GRILLE, la grille de jeu
--	      Fle_n: (D), entier, dimension reelle de la grille
--	      Fle_joueur: (D), JOUEUR, le joueur courant
--Preconditions: Toute case de la grille contient une valeur significative
--               M_MIN<= Fle_n <=N_MAX
--Postconditions: la grille et le joueur courant sont affichés
--Exceptions:_

procedure afficher_jeu(Fla_grille:in GRILLE;Fle_n:in integer;Fle_joueur:in JOUEUR) is
begin
  --Afficher le joueur courant de maniere conviviale
  new_line;
  put("Le joueur courant est: ");
  if Fle_joueur=JBLEU then
    put_line("JBLEU (B)");new_line;
  else
    put_line("JROUGE (R)");new_line;
  end if;
  new_line;

  --Afficher la grille
  for i in reverse 1..Fle_n loop
    for j in 1..Fle_n loop
      if Fla_grille(i,j)=LIBRE then
	put("|   ");
      elsif Fla_grille(i,j)=BLEU then
	put("| B ");
      else 
	put("| R ");
      end if;
    end loop;
    new_line;
    for k in 1..Fle_n loop
      put("____");
    end loop;
    new_line;
  end loop;
end afficher_jeu;


--Fonction:case_ajout
--Retourne l'indice de la première case libre d'une colonne de la grille de
--jeu, afin d'y mettre un jeton
--Parametres: Fla_grille:(D), GRILLE, la grille de jeu
--            Fle_n:(D), entier, la dim reelle de la grille
--            Fcolonne:(D), entier, la colonne de la grille
--Preconditions: Toute case de Fla_grille contient une valeur significative
--               M_MIN<=Fle_n<=N_MAX
--               1<=Fcolonne<=Fle_n
--               Fla_grille(Fle_n,Fcolonne)=LIBRE, ie: la colonne contient
--               au moins une case libre
--Type retour: entier
--Postconditions: indice de la première case libre de la colonne, compris
--                entre 1 et Fle_n

function case_ajout(Fla_grille:in GRILLE;Fle_n:in integer;Fcolonne:in integer) return integer is
ligne:integer;	  --le resultat: indice de la 1ere case libre de Fcolonne
begin
  ligne:=1;
  while ligne<=Fle_n and then Fla_grille(ligne,Fcolonne)/=LIBRE loop
    ligne:=ligne+1;
  end loop;
  --Fla_grille(ligne,Fcolonne)=LIBRE (car precondition: la colonne contient
  --au moins une case libre
  return ligne;
end case_ajout;


--Fonction: grille_pleine
--Indique si une grille de jeu est pleine (aucune case LIBRE) ou non
--Parametres: Fla_grille:(D), GRILLE, la grille de jeu
--            Fle_n: (D), entier, dim reelle de la grille
--Preconditions: Toute case de la grille contient une valeur significative
--               M_MIN<=Fle_n<=N_MAX
--Type retour:booleen
--Postcondition:vrai si la grille est pleine, faux sinon
--Exceptions:_

function grille_pleine(Fla_grille:in GRILLE;Fle_n:in integer) return boolean is
est_pleine:boolean;	--contient le resultat
case_libre:boolean;     --indique qu'une case est libre
ligne:integer;		--pour le parcours des lignes
colonne:integer;	--pour le parcours des colonnes
begin
  case_libre:=false;
  ligne:=1;
  while (ligne<=Fle_n and not case_libre) loop
    colonne:=1;
    while (colonne<=Fle_n and then Fla_grille(ligne,colonne)/=LIBRE) loop
      colonne:=colonne+1;
    end loop;
    --colonne>Fle_n ou Fla_grille(ligne,colonne)=LIBRE
    if colonne>Fle_n then
      --La ligne courante est pleine, on passe à la suivante
      ligne:=ligne+1;
    else
      --La ligne courante n'est pas pleine,donc la grille n'est pas pleine
      case_libre:=true;
    end if;
  end loop;
  --ligne>Fle_n ou case_libre
  if ligne>Fle_n then 
    --aucune case n'est LIBRE
    est_pleine:=true;
  else
    --il y a au moins une case LIBRE
    est_pleine:=false;
  end if;
  return est_pleine;
end grille_pleine;


--Fonction:align_horiz
--Indique si la grille contient un alignement horizontal de m symboles identiques
--Parametres: Fla_grille:(D), GRILLE, la grille
--	      Fle_n:(D), entier, dim reelle de la grille
--	      Fle_m:(D), entier, taille min d'un alignement
--Preconditions: Toute case de la grille contient une valeur signficative
--               M_MIN<= Fle_n <=N_MAX
--               M_MIN<=Fle_m<=Fle_n
--Type retour: booleen
--Postconditions: vrai s'il y a un alignement horizontal, faux sinon
--Exceptions:_

function align_horiz(Fla_grille:in GRILLE;Fle_n:in integer;Fle_m:in integer) return boolean is
alignement:boolean;	--contient le resultat
ligne:integer;		--pour le parcours des lignes
colonne:integer;	--pour le parcours des colonnes
nb_ident:integer;	--compteur pour les symboles successifs identiques
begin
  alignement:=false;
  nb_ident:=1;
  ligne:=1;
  while (ligne<=Fle_n and not alignement) loop
    colonne:=1;
    --trouve:=false;
    while colonne<Fle_n and not alignement loop
      if (Fla_grille(ligne,colonne)/=LIBRE and then Fla_grille(ligne,colonne)=Fla_grille(ligne,colonne+1)) then
	nb_ident:=nb_ident+1;
      else
	nb_ident:=1;
      end if;
      if nb_ident>=Fle_m then
	alignement:=true;
      else
      colonne:=colonne+1;
    end if;
    end loop;
    --colonne=Fle_n ou alignement
    ligne:=ligne+1;
  end loop;
  --ligne>Fle_n ou alignement
  return alignement;
end align_horiz;


--Fonction:align_vert
--Indique si la grille contient un alignement vertical de m symboles identiques
--Parametres: Fla_grille:(D), GRILLE, la grille
--	      Fle_n:(D), entier, dim reelle de la grille
--	      Fle_m:(D), entier, taille min d'un alignement
--Preconditions: Toute case de la grille contient une valeur signficative
--               M_MIN<= Fle_n <=N_MAX
--               M_MIN<=Fle_m<=Fle_n
--Type retour: booleen
--Postconditions: vrai s'il y a un alignement vertical, faux sinon
--Exceptions:_

function align_vert(Fla_grille:in GRILLE;Fle_n:in integer;Fle_m:in integer) return boolean is
alignement:boolean;	--contient le resultat
ligne:integer;		--pour le parcours des lignes
colonne:integer;	--pour le parcours des colonnes
nb_ident:integer;	--compteur pour les symboles successifs identiques
begin
  alignement:=false;
  nb_ident:=1;
  colonne:=1;
  while (colonne<=Fle_n and not alignement) loop
    ligne:=1;
    while ligne<Fle_n and not alignement loop
      if Fla_grille(ligne,colonne)/=LIBRE and then Fla_grille(ligne,colonne)=Fla_grille(ligne+1,colonne) then
	nb_ident:=nb_ident+1;
      else
	nb_ident:=1;
      end if;
      if nb_ident>=Fle_m then
	alignement:=true;
      else
      ligne:=ligne+1;
    end if;
    end loop;
    --ligne=Fle_n ou alignement
    colonne:=colonne+1;
  end loop;
  --colonne>Fle_n ou alignement
  return alignement;
end align_vert;


--Fonction:align_diag_droit
--Indique si la grille contient un alignement diagonal droit (ie du bas vers
--le haut, de gauche à droite) de m symboles identiques
--Parametres: Fla_grille:(D), GRILLE, la grille
--	      Fle_n:(D), entier, dim reelle de la grille
--	      Fle_m:(D), entier, taille min d'un alignement
--Preconditions: Toute case de la grille contient une valeur signficative
--               M_MIN<= Fle_n <=N_MAX
--               M_MIN<=Fle_m<=Fle_n
--Type retour: booleen
--Postconditions: vrai s'il y a un alignement diagonal droit, faux sinon
--Exceptions:_

function align_diag_droit(Fla_grille:in GRILLE;Fle_n:in integer;Fle_m:in integer) return boolean is
alignement:boolean;	--contient le resultat
ligne:integer;		--pour le parcours des lignes
colonne:integer;	--pour le parcours des colonnes
nb_ident:integer;	--compteur pour les symboles successifs identiques
aux_ligne:integer;	--pour parcours des lignes dans la boucle imbriquee
begin
  alignement:=false;
  nb_ident:=1;
  ligne:=1;
  while (ligne<=Fle_n and not alignement) loop
    aux_ligne:=ligne;
    colonne:=1;
    while aux_ligne<Fle_n and colonne<Fle_n and not alignement loop
      if (Fla_grille(aux_ligne,colonne)/=LIBRE and Fla_grille(aux_ligne,colonne)=Fla_grille(aux_ligne+1,colonne+1)) then
	nb_ident:=nb_ident+1;
      else
	nb_ident:=1;
      end if;
      if nb_ident>=Fle_m then
	alignement:=true;
      else
	if nb_ident=1 then
	  colonne:=colonne+1;
	else
	  aux_ligne:=aux_ligne+1;
	  colonne:=colonne+1;
	end if;
    end if;
    end loop;
    --colonne=Fle_n ou aux_ligne=Fle_n ou alignement
    ligne:=ligne+1;
  end loop;
  --ligne>Fle_n ou alignement
  return alignement;
end align_diag_droit;


--Fonction:align_diag_gauche
--Indique si la grille contient un alignement diagonal gauche (ie du bas vers le haut, de droite à gauche) de m symboles identiques
--Parametres: Fla_grille:(D), GRILLE, la grille
--	      Fle_n:(D), entier, dim reelle de la grille
--	      Fle_m:(D), entier, taille min d'un alignement
--Preconditions: Toute case de la grille contient une valeur signficative
--               M_MIN<= Fle_n <=N_MAX
--               M_MIN<=Fle_m<=Fle_n
--Type retour: booleen
--Postconditions: vrai s'il y a un alignement diagonal gauche, faux sinon
--Exceptions:_

function align_diag_gauche(Fla_grille:in GRILLE;Fle_n:in integer;Fle_m:in integer) return boolean is
alignement:boolean;	--contient le resultat
ligne:integer;		--pour le parcours des lignes
colonne:integer;	--pour le parcours des colonnes
nb_ident:integer;	--compteur pour les symboles successifs identiques
aux_ligne:integer;
begin
  alignement:=false;
  nb_ident:=1;
  ligne:=1;
  while (ligne<Fle_n and not alignement) loop
    aux_ligne:=ligne;
    colonne:=Fle_n;
    while aux_ligne<Fle_n and colonne>1 and not alignement loop
      if (Fla_grille(aux_ligne,colonne)/=LIBRE and Fla_grille(aux_ligne,colonne)=Fla_grille(aux_ligne+1,colonne-1)) then
	nb_ident:=nb_ident+1;
      else
	nb_ident:=1;
      end if;
      if nb_ident>=Fle_m then
	alignement:=true;
      else
	if nb_ident=1 then
	  colonne:=colonne-1;
	else
	  aux_ligne:=aux_ligne+1;
          colonne:=colonne-1;
	end if;
      end if;
    end loop;
    --colonne=1 ou aux_ligne>=Fle_n ou alignement
    ligne:=ligne+1;
  end loop;
  --ligne=Fle_n ou alignement
  return alignement;
end align_diag_gauche;


--Procedure jouer
--Realiser le mouvement du joueur courant et calculer le nouvel etat du jeu
--ou changer le joueur courant
--Parametres: Fla_grille:(D/R), GRILLE, la grille de jeu
--	      Fle_n:(D), entier, la dim reelle de la grille
--	      Fle_m:(D), entier, taille min d'un alignement
--	      Fl_etat:(D/R), ETAT_JEU, l'etat de la partie
--	      Fle_joueur:(D/R), JOUEUR, le joueur courant
--Preconditions: Toute case de la grille contient une valeur significative
--               M_MIN<= Fle_n <=N_MAX
--               M_MIN<= Fle_m <=Fle_n
--               Fl_etat=EN_COURS
--Postconditions: La grille contient une case LIBRE en moins
--                Soit l'etat du jeu change, soit le joueur courant change
--Exceptions:_

procedure jouer(Fla_grille:in out GRILLE;Fle_n:in integer;Fle_m:in integer;Fl_etat:in out ETAT_JEU;Fle_joueur:in out JOUEUR) is
choix_colonne:integer;		--choix du joueur courant
ligne:integer;			--ligne de l'ajout
win:boolean;		--indique s'il y a un alignement de symboles identiques
begin
  loop
    new_line;
    put_line("Choisissez une colonne pour déposer un jeton:");
    get(choix_colonne);
    exit when((1<=choix_colonne and choix_colonne<=Fle_n) and then Fla_grille(Fle_n,choix_colonne)=LIBRE);
  end loop;
  --1<=choix_colonne<=Fle_n et Fla_grille(Fle_n,choix_colonne)=LIBRE (ie la colonne n'est pas pleine)

  --Calculer la premiere case libre de la colonne choisie
  --1<=choix_colonne<=Fle_n et Fla_grille(Fle_n,choix_colonne)=LIBRE:preconditions verifiees
  ligne:=case_ajout(Fla_grille,Fle_n,choix_colonne);
  --Deposer le jeton
  if Fle_joueur=JBLEU then
    Fla_grille(ligne,choix_colonne):=BLEU;
  else
    Fla_grille(ligne,choix_colonne):=ROUGE;
  end if;

  --Chercher un alignement de symboles identiques
  --M_MIN<=Fle_n<=N_MAX et M_MIN<=Fle_m<=Fle_n: preconditions verifiees
  win:=align_horiz(Fla_grille,Fle_n,Fle_m) or align_vert(Fla_grille,Fle_n,Fle_m) or align_diag_droit(Fla_grille,Fle_n,Fle_m) or align_diag_gauche(Fla_grille,Fle_n,Fle_m);
  

  if win then
    Fl_etat:=GAGNE;
  else
    --Verifier si la grille est pleine
    --M_MIN<=Fle_n<=N_MAX: precondition verifiee
    if grille_pleine(Fla_grille,Fle_n) then
      Fl_etat:=NUL;
    else
      --Changer le joueur courant
      if Fle_joueur=JBLEU then
	Fle_joueur:=JROUGE;
      else
	Fle_joueur:=JBLEU;
      end if;
    end if;
  end if;
end jouer;


--Procedure: afficher_fin_de_jeu
--Afficher la grille à la fin d'une partie, le resultat et le joueur gagnant s'il y en a
--Parametres: Fla_grille:(D), GRILLE, la grille de jeu
--	      Fle_n:(D), entier, la dim reelle de la grille
--	      Fle_joueur:(D), JOUEUR, le joueur courant
--	      Fl_etat:(D), ETAT_JEU, l'etat de la partie
--Preconditions: Toute case de la grille contient une valeur significative
--               M_MIN<= Fle_n <=N_MAX
--               Fl_etat=NUL ou Fl_etat=GAGNE
--Postconditions: Le resultat de la partie est affiche
--Exceptions:_

procedure afficher_fin_de_jeu(Fla_grille:in GRILLE; Fle_n:in integer; Fle_joueur:in JOUEUR; Fl_etat:in ETAT_JEU) is
begin
  new_line;
  put_line("PARTIE TERMINEE!");
  new_line;

  --Afficher la grille finale
  for i in reverse 1..Fle_n loop
    for j in 1..Fle_n loop
      if Fla_grille(i,j)=LIBRE then
	put("|   ");
      elsif Fla_grille(i,j)=BLEU then
	put("| B ");
      else 
	put("| R ");
      end if;
    end loop;
    new_line;
    for k in 1..Fle_n loop
      put("____");
    end loop;
    new_line;
  end loop;

  --Le resultat
  new_line;
  put_line("Resultat:");
  new_line;
  if Fl_etat=NUL then
    put_line("MATCH NUL!");
  else
    if Fle_joueur=JBLEU then
      put_line("BLEU a gagne!");
    else
      put_line("ROUGE a gagne!");
    end if;
  end if;
end afficher_fin_de_jeu;


la_grille:GRILLE;	--Espace de jeu
le_n:integer;		--Dimensin reelle de la grille, M_MIN<=le_n<=N_MAX
le_m:integer;		--Taille min d'un alignement
le_joueur:JOUEUR;	--Le joueur courant
l_etat:ETAT_JEU;	--L'etat courant du jeu

begin
  --Initialiser le jeu
  --Pas de preconditions pour initialiser_jeu
  initialiser_jeu(la_grille,le_n,le_m,l_etat,le_joueur);
  
  --Jouer
  loop
    --Afficher la grille de jeu et le joueur courant
    if M_MIN<=le_n and le_n<=N_MAX then
      --precondition verifiee
      afficher_jeu(la_grille,le_n,le_joueur);
    else
      put_line("Preconditions invalides pour afficher!");
    end if;
    --Le joueur courant joue
    if l_etat=EN_COURS and M_MIN<=le_n and le_n<=N_MAX and M_MIN<=le_m and le_m<=le_n then
      --Preconditions verifiees
      jouer(la_grille,le_n,le_m,l_etat,le_joueur);
    else
      put_line("Preconditions invalides pour jouer!");
    end if;
  exit when l_etat/=EN_COURS;
  end loop;
  --partie terminee: l_etat/=EN_COURS
  --Afficher le resultat final
  if l_etat=NUL or l_etat=GAGNE then
    --preconditions verifiees
    afficher_fin_de_jeu(la_grille,le_n,le_joueur,l_etat);
  else
    put_line("Preconditions invalides pour afficher_fin_de_jeu!");
  end if;
end puissance_m;




























































