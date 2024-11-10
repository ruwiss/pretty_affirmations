import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:pretty_affirmations/ui/widgets/appbar_widget.dart';

class StoriesView extends StatelessWidget {
  const StoriesView({super.key});

  final String text = """
Bir zamanlar, içsel huzuru bulmak için sürekli dışarıda bir şeyler arayan bir genç vardı: Mert. Mert, hayatını başarıya, başkalarının onayına ve mükemmel olmaya adadığı için içindeki boşluğu bir türlü dolduramıyordu. Her şeyin eksik olduğunu hissediyor, kendini sevmenin nasıl mümkün olabileceğini bir türlü anlayamıyordu.

Bir gün, kasabaya yeni bir kitapçı açıldı ve Mert merakla dükkânın kapısından içeri girdi. Kitapçı, sakin ve huzurlu bir yerdi; raflarda binlerce kitap sıralanmıştı. Bir köşede, yaşlıca bir adam elindeki kitabı okurken Mert’in dikkatini çekti. Yaşlı adam ona gülümsedi ve “Olumlamanın gücünden haberdar mısın?” diye sordu.

Mert, “Olumlama mı? O da ne?” diye sordu şaşkın bir şekilde.

Yaşlı adam kitabını kapatarak, “Olumlama, kendini sevmenin, hayatını değiştirmeye başlamanın ilk adımıdır. Kendine her gün pozitif şeyler söylemek, seni olumlu bir insan yapar,” dedi. “Mesela ‘Ben değerliyim,’ ‘Hayatımda güzel şeyler oluyor,’ ‘Her gün daha iyiye gidiyorum.’ Bunları her sabah kendine söyle, ve zamanla göreceksin ki, hayatındaki her şey değişmeye başlayacak.”

Mert, yaşlı adamın önerisini içtenlikle dinledi ve eve dönerken düşündü: “Kendimi sevmek için belki de dışarıda aradığım şeyi, aslında içimde bulmalıyım.”

Ertesi sabah, ilk kez kendine bakarak “Ben değerliyim” dedi. Gözleri parlamasa da, içinde küçük bir umut kıvılcımı yanmaya başlamıştı. Günler geçtikçe, her sabah olumlamalarını yaparak içsel bir değişim fark etti. Kendini daha güçlü, daha sevgi dolu ve daha huzurlu hissediyordu.

Aylar sonra, Mert kasabanın en mutlu ve en pozitif insanlarından biri haline geldi. Kendini sevmek için attığı ilk adım, hayatını bambaşka bir yola sokmuştu.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: S.of(context).stories),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _datetimeNowText(context),
              const Gap(15),
              const Text(
                "Kendini Sevmek İçin İlk Adım: Olumlama",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  wordSpacing: 1.2,
                ),
              ),
              const Gap(12),
              Text(
                text,
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 20),
              )
            ],
          ),
        ),
      ),
    );
  }

  Text _datetimeNowText(BuildContext context) {
    return Text(
      DateTime.now().yearAbbrMonthDay,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: context.colors.primaryFixed,
      ),
    );
  }
}
