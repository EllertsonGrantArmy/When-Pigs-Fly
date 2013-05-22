int Senval=0;

int Senpin=A0;

void setup()
{
    Serial.begin(9600);
}

void loop()
{

    Senval=analogRead(Senpin);
    Serial.println(Senval);
    

    delay(300);
}
