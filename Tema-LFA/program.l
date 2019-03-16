/* Jorascu Marian Vladut 335CC */
%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#define NUMAR_MAXIM_OBIECTE 100
	#define DIMENSIUNE_MAXIMA_NUME 500
	
	#undef yywrap	
	char * a;

	//Indicele obiectului curent, ale carui informatii se proceseaza
	//la un anumit pas
	int i = -1;
	
	//Pentru fiecare Obiect propriuzis variabilele de mai jos retin diferite date
	int NrObiecteComponente[NUMAR_MAXIM_OBIECTE] = {0};
	int NrVarfuri[NUMAR_MAXIM_OBIECTE] = {0}, NrTexturi[NUMAR_MAXIM_OBIECTE] = {0}
		, NrNormale[NUMAR_MAXIM_OBIECTE] = {0};
	//Numarul de fete descrise cu ajutorul indicilor, coord. de texturare, normalelor
	//ale ficarui obiect
	int NrFete[NUMAR_MAXIM_OBIECTE] = {0}, NrFeteT[NUMAR_MAXIM_OBIECTE] = {0},
		NrFeteN[NUMAR_MAXIM_OBIECTE] = {0};
	//Numarul fetelor descrise atat cu coordonatele de texturare cat si cu normale
	int NrFeteTN[NUMAR_MAXIM_OBIECTE] = {0};
	
	//Un vector bidimensional de stringuri in care se retin numele obiectelor
	char **Nume ;
	//Un sir de caractere in care se salveaza numele tuturor obiectelor 
	char *NumeObiecteTotal;
	//Un vector tridimensional in care se retin pentru fiecare obiect in parte
	//numele obiectelor componente 
	char ***NumeComponente;
	//Flag care imi specifica daca fata curenta este a unui obiect sau a unui obiect component
	int sw = 0;
	//Vectori care retin pentru obiecte , numarul de fete ale obiectelor componente
	int NrFeteComp[NUMAR_MAXIM_OBIECTE][NUMAR_MAXIM_OBIECTE] = {0}, 
		NrFeteTComp[NUMAR_MAXIM_OBIECTE][NUMAR_MAXIM_OBIECTE] = {0}
	    , NrFeteNComp[NUMAR_MAXIM_OBIECTE][NUMAR_MAXIM_OBIECTE] = {0};
	int NrFeteTNComp[NUMAR_MAXIM_OBIECTE][NUMAR_MAXIM_OBIECTE] = {0};
%}


DelimitatoriIntern [\t ]
cifra [0-9]
semn [+-]?
Natural {cifra}+	
Real {semn}{Natural}\.{Natural}?

DateVarf {Real}{DelimitatoriIntern}+
Varf v{DelimitatoriIntern}+{DateVarf}{2,3}{Real}{DelimitatoriIntern}*
Delimitatori [\n\t ]*
DelimitatoriAuxiliar [\n\t ]*

Unu "1.0"|"1"|"0"
NrSubunitar "0"\.{Natural}
Subunitar {Unu}{DelimitatoriIntern}+|{NrSubunitar}{DelimitatoriIntern}+
Subunitar2 {Unu}{DelimitatoriIntern}*|{NrSubunitar}{DelimitatoriIntern}*

Normala "vn"{DelimitatoriIntern}+{Subunitar}{2}{Subunitar2}
Texturare "vt"{DelimitatoriIntern}+{Subunitar}{1,2}{Subunitar2}

FataSimplaAux {Natural}{DelimitatoriIntern}+
FataSimplaAux2 {Natural}{DelimitatoriIntern}*
/*Fata care este descrisa doar folosind indici*/
FataSimpla f{DelimitatoriIntern}+{FataSimplaAux}{2,}{FataSimplaAux2}

FataTAux {Natural}\/{Natural}{DelimitatoriIntern}+
FataTAux2 {Natural}\/{Natural}{DelimitatoriIntern}*
/*Fata care este descrisa folosind indicii varufilor
 si coordonate de tecturare*/
FataT f" "+{FataTAux}{2,}{FataTAux2}

FataNAux {Natural}\/\/{Natural}{DelimitatoriIntern}+
FataNAux2 {Natural}\/\/{Natural}{DelimitatoriIntern}*
/*Fata care este descrisa folosind indicii varfurilor si normale*/
FataN f{DelimitatoriIntern}+{FataNAux}{2,}{FataNAux2}

FataTNAux {Natural}\/{Natural}\/{Natural}{DelimitatoriIntern}+
FataTNAux2 {Natural}\/{Natural}\/{Natural}{DelimitatoriIntern}*
/*Fata care este descrisa folosind indicii varfurilor, 
coordonate de texturare si normale*/
FataTN f{DelimitatoriIntern}+{FataTNAux}{2,}{FataTNAux2}

/*Expresie care descrie numele unui Obiect Component sau numele
unui obiect*/
NumeObiectComponent [a-zA-Z][a-zA-Z0-9_]*



/*Starea in care se citeste un caracter sau doua si se anticipeaza ce fel
de componenta este descrisa in acea linie, si se va trece in starea
corespunzatoare*/
%x DECIZIE 
%x VARF NORMALA TEXTURA 
/*Starea in care se proceseaza fetele sub diferitele forme
sub care pot fi descrise*/
%x FATA 
/*Stare in care se proceseaza numele obiectelor componente 
ale fiecarui obiect particular */
%x OBIECTCOMPONENT 
/*Stare in care se proceseaza numele obiectului propriuzis*/
%x OBIECTPROPRIUZIS 
/*Stare in care se proceseaza fiecare delimitator
de rand , din cadrul unei linii ce contine informatie utila*/
%x SFARSITLINIE

%%
 
<INITIAL>{DelimitatoriAuxiliar} {
								//Pe aceasta regula se face match daca definirea
								//obiectului este chiar la inceputul obiectului
								}	 
<INITIAL>[a-z] {	
					//Verific daca am un singur obiect
					if(yytext[0] != 'o'){
						i++;
						yyless(0);
						BEGIN(DECIZIE);
					}
					else{
						yyless(0);
						BEGIN(DECIZIE);
					}
				}

<DECIZIE>[a-z]{2} {
						//Se trece in starea corespunzatoare liniei curente
						if(yytext[0] == 'v' && yytext[1] == 'n'){
							yyless(0);
							BEGIN(NORMALA);
						}
						if(yytext[0] == 'v' && yytext[1] == 't'){
							yyless(0);
							BEGIN(TEXTURA);
						}
				  } 
		   
<DECIZIE>[a-z] {
					//Se trece in starea corespunzatoare liniei curente
					if(yytext[0] == 'v'){
						yyless(0);
						BEGIN(VARF);
					}
					if(yytext[0] == 'f'){
						yyless(0);
						BEGIN(FATA);
					}
					
					if(yytext[0] == 'g'){
						BEGIN(OBIECTCOMPONENT);
					}
					
					if(yytext[0] == 'o'){
						i++;
						//Resetam flagul la 0 cu fiecare obiect nou
						sw = 0;
						BEGIN(OBIECTPROPRIUZIS);
					}
				}


<OBIECTPROPRIUZIS>{DelimitatoriIntern}+ {}

<OBIECTPROPRIUZIS>{NumeObiectComponent} {
										//Adaug numele obiectului curent
										strcat(NumeObiecteTotal, yytext);
										strcat(NumeObiecteTotal, ", ");
										Nume[i] = calloc(yyleng, 1);
										strcpy(Nume[i], yytext);
										BEGIN(SFARSITLINIE);
									}	
									
<OBIECTCOMPONENT>{DelimitatoriIntern}+ {}

<OBIECTCOMPONENT>{NumeObiectComponent} {
										//Procesez numele obiectului component curent 
										NrObiecteComponente[i]++;
										strcat(NumeComponente[i][0], yytext);
										strcat(NumeComponente[i][0],", ");
										//Marchez faptul ca fata ce urmeaza apartine
										//unui obiect component 
										sw = NrObiecteComponente[i];
										NumeComponente[i][sw] = calloc(yyleng, 1);
										strcpy(NumeComponente[i][sw], yytext);
										BEGIN(SFARSITLINIE);
	
									}

<VARF>{Varf} {
				 //Actualizez numarul de varfuri pentru obiectul curent 
				 NrVarfuri[i]++;
				 BEGIN(SFARSITLINIE);
			 }
			
<NORMALA>{Normala} {
						//Actualizez numarul de normale pentru obiectul curent
						NrNormale[i]++;
						BEGIN(SFARSITLINIE);
				   }

<TEXTURA>{Texturare} {
						//Actualizez numarul de cooronate de texturare pentru obiectul curent
						NrTexturi[i]++;
						BEGIN(SFARSITLINIE);
					 }
					

<FATA>{FataSimpla} {
						//Verific daca fata curenta este corespunzatoare
						//unui obiect component sau celui curent
						if(sw == 0){
							NrFete[i]++;
						}
						else{
							NrFeteComp[i][sw]++;
						}
						BEGIN(SFARSITLINIE);
				   }
				   
<FATA>{FataT} {
					if(sw == 0)
						NrFeteT[i]++;
					else{
						NrFeteTComp[i][sw]++;
					}
					BEGIN(SFARSITLINIE);
			  }

<FATA>{FataN} {
					if(sw == 0)
						NrFeteN[i]++;
					else{
						NrFeteNComp[i][sw]++;
					}
					BEGIN(SFARSITLINIE);
			 }
			 
<FATA>{FataTN} {
					if(sw == 0){
						NrFeteTN[i]++;
					}
					else{
						NrFeteTNComp[i][sw]++;
					}
					BEGIN(SFARSITLINIE);
				}
			
<SFARSITLINIE>\n { 
					//Fiecare "componenta" a unui obiect este pe o linie separata 
					//astfel nu trebuie sa urmeze dupa ea decat separatorul de linii
					BEGIN(DECIZIE);}
<DECIZIE>{Delimitatori} {
							//In cazul delimitatorilor dintre linii nu trebuie sa 
							//facem nicio procesare
						}

%%

int yywrap(){}
main(int argc, char **argv)
{
	//Aloc sirurile de caractere
	Nume = malloc(sizeof(char *) * NUMAR_MAXIM_OBIECTE);
	NumeComponente = malloc(sizeof(char **) * NUMAR_MAXIM_OBIECTE);
	NumeObiecteTotal = calloc(DIMENSIUNE_MAXIMA_NUME, 1);
	
	int j,k;
	for(j = 0 ; j < NUMAR_MAXIM_OBIECTE ; j++){
		Nume[j] = NULL;
		NumeComponente[j] = calloc(DIMENSIUNE_MAXIMA_NUME, sizeof(char *));
	}
	for(j = 0 ; j < NUMAR_MAXIM_OBIECTE ; j++){
		NumeComponente[j][0]	 = calloc(DIMENSIUNE_MAXIMA_NUME, 1);
	}

	yyin  = fopen(argv[1], "r");
	if(!yyin){
		printf("S-a produs o eroare nu se poate efectua citirea\n");
		exit(1);
	}

	//Pornesc analizorul lexical
	yylex();
	if(i >= 1)
		printf("%i obiecte: ",(i + 1));
	else{
		if(Nume[0] == NULL)
			printf("%i obiect ",(i + 1));
		else	
			printf("%i obiect: ",(i + 1));
	}
	
	
	
	NumeObiecteTotal[strlen(NumeObiecteTotal) - 2] = 0;
	if(NumeObiecteTotal[0] != 0)
		printf("%s ", NumeObiecteTotal);
	
	printf("\n");
	
	int suma = 0;
	for(j = 0 ; j <= i ; j++)
	{
		//AFISEZ NUMELE DACA EXISTA
		if(Nume[j] != NULL)
		{
			printf("%s \n", Nume[j]);
		}
	
		if(NrObiecteComponente[j] == 0){
			printf("Nu exista obiecte componente\n");
		}
		else
		{
			NumeComponente[j][0][strlen(NumeComponente[j][0]) - 2] = 0;
			printf("%i obiecte componente: %s\n", NrObiecteComponente[j], NumeComponente[j][0]);
			
			for(k = 1 ; k <= NrObiecteComponente[j] ; k++)
			{
				suma = NrFeteComp[j][k] +  NrFeteTComp[j][k] + NrFeteNComp[j][k] + NrFeteTNComp[j][k];
				if(suma > 1)
					printf("%s: %d fete: ", NumeComponente[j][k], suma);
				else
					printf("%s: %d fata ",NumeComponente[j][k], suma);
				
				suma = NrFeteTComp[j][k] + NrFeteTNComp[j][k];
				if(suma > 0)
				{
					if(suma > 1)
					printf("%d fete definite cu coordonate de texturare", suma);
					else
						printf("%d fata definita cu coordonata de texturare", suma);
				}
				
				suma = NrFeteTNComp[j][k] + NrFeteNComp[j][k];
				if(suma > 0)
				{
					if(suma > 1)
						printf("%d fete definite cu normale",suma);
					else
						printf("%d fata definita cu normala",suma);
				}
				printf("\n");
			}
		}
		
		
		if(NrVarfuri[j] != 0){
			printf("%i varfuri\n", NrVarfuri[j]);
		}
		if(NrTexturi[j] != 0){
			printf("%i coordonate de texturare\n",NrTexturi[j]);
		}
		
		if(NrNormale[j] != 0){
			printf("%i normale\n",NrNormale[j]);
		}
		
		
		suma = 0;
		suma = NrFete[j] + NrFeteT[j] + NrFeteN[j] + NrFeteTN[j];
		if(suma != 0){
			if(NrFeteT[j] == NrFeteN[j] && NrFeteT[j] == NrFeteTN[j]
				&& NrFeteT[j] == 0){
				printf("%d fete ",suma);		
			}
				
			else{
				printf("%d fete: ",suma);
			}
			
			suma = NrFeteT[j] + NrFeteTN[j];
			if(suma > 0)
			{
				if(suma > 1)
					printf("%d fete definite cu coordonata de texturare, ", suma);
				else	
					printf("%d feta definita cu coordonata de texturare, ", suma);
			}
			
			suma = NrFeteN[j] + NrFeteTN[j];
			if(suma > 0)
			{
				if(suma > 1)
					printf("%d fete definite cu normale", suma);
				else	
					printf("%d feta definita cu normala", suma);
			}
			printf("\n");
		}
	}
	
	return 0;
}