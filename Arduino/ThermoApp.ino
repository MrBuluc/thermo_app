#define led 3 //3.Pinde LED olduğunu tanımlıyoruz

int lm35=A1; //A1 anolog pinindeki değeri lm35 degerine tanımlıyoruz. 
int ldr = A0;
void setup()
{
  analogReference(INTERNAL);
  Serial.begin(9600);  //Serial haberleşme açıldı.
  pinMode(led, OUTPUT); //LED'in çıkış elemanı olduğunu belirtiyoruz
  //pinMode(ldr, INPUT);
  //pinMode(lm35, INPUT);
}

void loop()
{
ledYak(isikOlc());
delay(10);
sicaklikOlc();
Serial.println("********************************************");
delay(1000); //Bu döngünün 1 sn içinde sürekli tekrar etmesini istiyoruz.

/*float tem = analogRead(lm35);
tem = analogRead(lm35);
tem = tem * (5*100/1024);

float ldrValue = analogRead(ldr);
ldrValue = analogRead(ldr);

Serial.print("Tem: ");
Serial.println(tem);
Serial.print("LDR: ");
Serial.println(ldrValue);
Serial.println("**************************************************");
delay(1000);*/
}

/*
 * Kodlara geçmeden önce LM35 analog çıkış pini sıcaklıkla orantılı olarak 0 ile 1.1 V arasında çıkış vermektedir. 
 * Bu nedenle analog pinden alınan 5V çıkışı 0 ile 1.1 V arasında çıkış verecek şekilde düzenlemeliyiz.

Bu işlem için analogReference (INTERNAL); komutunu kullanmalıyız. 
analogReference (); komutu, analog giriş için kullanılan referans voltajını yapılandırır. Bu sayede LM35 sıcaklık sensöründen en hassas şekilde yararlanabiliriz.

Normalde analog çıkışlardan 0 ve 5V için 0 ile 1023 arasında çıkış almaktayız. Fakat  analogReference (); komutuyla analog çıkışı 0-1.1V (1100 mV) arasına indirgedik. 
Bu durumda her bir analog sinyale karşılık gelen miliVolt değerini hesaplamalıyız. Bu işlem için 1024/1100=0,931 yaklaşık değeri elde edilmektedir. 
Her 10 mV değişim 1 ℃ sıcaklığa karşılık geldiğini söylemiştik. 
Bu durumda sensörden okunan analog değeri 10 x 0,931 =9,31 değerine böldüğümüzde ölçülen sıcaklık değerini tespit etmiş oluruz.
 */

void sicaklikOlc() {
int deger= analogRead(lm35); //deger degişkenini lm35den gelen degere tanımlıyoruz.
deger = analogRead(lm35);
float voltaj= deger* (5000/1024.0); //Lm35 sıcaklık degerinin hesaplamasını yapıyoruz. 
//float sicaklik= voltaj/100.0;
float sicaklik = deger / 9.31; //Lm35 sıcaklık degerinin hesaplamasını yapıyoruz. 
//float sicaklik = deger * (5 * 100 / 1024);
Serial.print("Sıcaklık Degeri: "); //  Serial ekrana sıcaklık degeri yazdırıyoruz.
Serial.print(sicaklik); // serial ekrana Sıcaklıgı yazdırıyoruz. 
Serial.println(" °C");//  Serial ekrana C yazdırıyoruz.
}

int isikOlc() {
  int isik = analogRead(ldr);
  isik = analogRead(ldr);
  Serial.print("Işık: ");
  Serial.println(isik);
  return isik;
}

void ledYak(int isik) {
  if (isik > 900) { //Okunan ışık değeri 900'den büyük ise
    digitalWrite(led, LOW); //LED yanmasın
  } else {
    digitalWrite(led, HIGH);  
  }
}
