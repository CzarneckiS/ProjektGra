
animacje chodzenia sa zdecydowanie zbyt subtelne, w ogole nie widac - do poprawy
state machine warriorow
ui placeholdery

rightclickowanie pojawia sie POD playerem
kolizje sa zwalone ale moze sie poprawia przy dobrym pathfindingu

jednostki z duza predkoscia przenikaja przez siebie - cos jest na rzeczy z physics process i process???

DO MOVEMENTU:
w warcrafcie jednostki nie ruszaja sie INSTANT kiedy tylko moga (co powoduje takie mikro
movementy) tylko dopiero kiedy bedzie jakis treshold
np kiedy odleglosc miedzy jednostka a targetem jest ponad 100 pixeli wtedy zacznij
sie ruszac

Player moze przepychac jednostki?? - jesli jednostka jest w idle i wykryje kolizje z graczem to odsuwa sie w kierunku przeciwnym od gracza????



https://www.reddit.com/r/godot/comments/108g2l0/will_godot_ever_get_a_fix_for_its_jittering_issue/
jesli beda problemy z jitterem i kamera to tu moze byc fix
