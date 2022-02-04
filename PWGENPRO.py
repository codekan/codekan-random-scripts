from random import *
import os

AbetStellen = randint(0, 25)
Randnum1 = randint(0, 25)
Randnum2 = randint(0, 28)
Abetklein= ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l","m", "n", "o", "p", "q", "r", "s", "t", "u",
            "v", "w", "x", "y", "z")
Abetgross= ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
            "V", "W", "X", "Y", "Z")
RSonderzeichen = ('!', '#', '$', '%', '&', '(', ')', '*', '+', ',', '-', '.', '/', ':', ';', '<', '=', '>', '?', '@',
                  '[', ']', '^', '_', '`', '{', '|', '}', '~')
RZahl = randint(0, 9)
PWminAnzahl = 6
count = 0
Passwort = ""
Wiederholung = "y"

Passwortquellzeichen = (Abetklein[Randnum1], Abetgross[AbetStellen], RZahl, RSonderzeichen[Randnum2])
#die pw stelle muss ne liste sein


while Wiederholung == "y":
    Passwort = ""
    count = 0
    PWminAnzahl = 6
    IstGueltigeEingabe = False
    PWmaxAnzahl= 30
    while not IstGueltigeEingabe:
        try:
            PasswortStellen = int(input("Wie viele Stellen soll das Passwort haben?(6-30 Stellen) : "))
            if PWmaxAnzahl < PasswortStellen or PasswortStellen < PWminAnzahl:
                print("Aus Sicherheitsgründen muss das Passwort mindestens 6 und maximal 30 Stellen lang sein!")
            else:
                IstGueltigeEingabe = True
        except ValueError:
            print("Ungültige Eingabe!")


    if PasswortStellen in range(6, 31):
        while count < PasswortStellen:
            count = count + 1
            AbetStellen = randint(0, 25)
            Randnum1 = randint(0, 25)
            RZahl = randint(0, 9)
            Randnum2 = randint(0, 28)
            Passwortquellzeichen = (Abetklein[Randnum1], Abetgross[AbetStellen], RZahl, RSonderzeichen[Randnum2])
            Passwort = Passwort + str(Passwortquellzeichen[randint(0, 3)])
        print("Dein zufällig generiertes Passwort lautet: " + str(Passwort))
    Wiederholung = input("Möchtest du noch ein Passwort generieren?(y/n): ")

    while Wiederholung is not "y":
        if Wiederholung is "n":
            quit("Das Programm wurde beendet.")
        else:
            Wiederholung = input("Ungültige Eingabe! Neues Passwort generieren?(y/n): ")

