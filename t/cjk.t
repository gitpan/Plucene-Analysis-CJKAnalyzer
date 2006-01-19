use Test::More tests => 37;
#use Test::More 'no_plan';

use utf8;
use Encode;
use Plucene::Document;
use Plucene::Document::Field;
use Plucene::Index::Writer;
use Plucene::Analysis::CJKAnalyzer;
use File::Path;
use Data::Dumper;

sub build_index {
  rmtree(['t/index'], 0, 0);
  my $writer = Plucene::Index::Writer->new("t/index",
					   Plucene::Analysis::CJKAnalyzer->new(), 1);
	local$/;
  my $id = 0;
  for (
	grep{!/^\s+$/}
	grep{!/^#/}
	grep{$_} 
	split /\n/, <DATA>){
    $id++;
#    next unless $id > 150;
#     last if $id > 20;
    printf "[%3d] %s\n", $id, $_;
    my $doc = Plucene::Document->new;
    $doc->add(Plucene::Document::Field->UnIndexed("id", $id));
    Encode::_utf8_on($_);
#    print $_,"\n";
    $doc->add(Plucene::Document::Field->Text("text", $_));
    $writer->add_document($doc);
  }
  $writer->optimize;
}

use Plucene::QueryParser;
use Plucene::Search::HitCollector;
use Plucene::Search::IndexSearcher;
sub search {
  my $parser = Plucene::QueryParser
    ->new({
           analyzer => Plucene::Analysis::CJKAnalyzer->new(),
           default  => 'text',
          });
  my $query_string = shift;
#  print $query_string , "\n";
  Encode::_utf8_on($query_string);
  my $query = $parser->parse($query_string);
#  print Dumper $query;
  my $searcher = Plucene::Search::IndexSearcher->new("t/index");

  my @docs;
  my $hc = Plucene::Search::HitCollector
    ->new(collect =>
          sub {
            my ($self, $doc, $score)= @_;
            push @docs, $searcher->doc($doc);
          });

  $searcher->search_hc($query, $hc);
  return @docs;
}

&build_index;

ok(-d 't/index');


my %h = qw(
甄士 1
一 6
咤 59
王熙鳳恃強羞說病 72
劉姥姥 6
怡紅院 17
あなたの筆先 127
青い空 129
チェスボ－ド 135
死者 143
春秋皆度百岁 151
半百而衰 156
왕의 157
앞서고 161
Mißhör 163
überwinden 164
Gefühle 171
119 119
);

foreach (keys %h){
 Encode::_utf8_on($_);
 if( ok(@d = &search($_)) ){
#   print $h{$_}, $_.' '.+(&search($_))[0]->get('id')->string(),$/;
   my $str = $d[0]->get('id')->string();
   is($str, $h{$_});
 }
}


__END__
# Traditional Chinese
      1 甄士隱夢幻識通靈　賈雨村風塵懷閨秀
      2 賈夫人仙逝揚州城　冷子興演說榮國府
      3 金陵城起復賈雨村　榮國府收養林黛玉
      4 薄命女偏逢薄命郎　葫蘆僧亂判葫蘆案
      5 開生面夢演紅樓夢　立新場情傳幻境情
      6 賈寶玉初試雲雨情　劉姥姥一進榮國府
      7 送宮花周瑞嘆英蓮　談肆業秦鐘結寶玉
      8 薛寶釵小恙梨香院　賈寶玉大醉絳芸軒
      9 戀風流情友入家塾　起嫌疑頑童鬧學堂
     10 金寡婦貪利權受辱　張太醫論病細窮源
     11 慶壽辰寧府排家宴　見熙鳳賈瑞起淫心
     12 王熙鳳毒設相思局　賈天祥正照風月鑑
     13 秦可卿死封龍禁尉　王熙鳳協理寧國府
     14 林如海捐館揚州城　賈寶玉路謁北靜王
     15 王鳳姐弄權鐵檻寺　秦鯨卿得趣饅頭庵
     16 賈元春才選鳳藻宮　秦鯨卿夭逝黃泉路
     17 大觀園試才題對額　怡紅院迷路探曲折
     18 林黛玉誤剪香袋囊　賈元春歸省慶元宵
     19 情切切良宵花解語　意綿綿靜日玉生香
     20 王熙鳳正言彈妒意　林黛玉俏語謔嬌音
     21 賢襲人嬌嗔箴寶玉　俏平兒軟語救賈璉
     22 聽曲文寶玉悟禪機　制燈迷賈政悲讖語
     23 西廂記妙詞通戲語　牡丹亭艷曲警芳心
     24 醉金剛輕財尚義俠　痴女兒遺帕惹相思
     25 魘魔法叔嫂逢五鬼　通靈玉蒙蔽遇雙真
     26 蜂腰橋設言傳密意　湘館春困發幽情
     27 滴翠亭楊妃戲彩蝶　埋香塚飛燕泣殘紅
     28 蔣玉菡情贈茜香羅　薛寶釵羞籠紅麝串
     29 享福人福深還禱福　痴情女情重愈斟情
     30 寶釵借扇機帶雙敲　齡官劃薔痴及局外
     31 撕扇子作千金一笑　因麒麟伏白首雙星
     32 訴肺腑心迷活寶玉　含恥辱情烈死金釧
     33 手足耽耽小動唇舌　不肖種種大承笞撻
     34 情中情因情感妹妹　錯裏錯以錯勸哥哥
     35 白玉釧親嘗蓮葉羹　黃金鶯巧結梅花絡
     36 繡鴛鴦夢兆絳芸軒　識分定情悟梨香院
     37 秋爽齋偶結海棠社　蘅蕪苑夜擬菊花題
     38 林瀟湘魁奪菊花詩　薛蘅蕪諷和螃蟹詠
     39 村姥姥是信口開合　情哥哥偏尋根究底
     40 史太君兩宴大觀園　金鴛鴦三宣牙牌令
     41 櫳翠庵茶品梅花雪　怡紅院劫遇母蝗蟲
     42 蘅蕪君蘭言解疑癖　瀟湘子雅謔補餘香
     43 閑取樂偶攢金慶壽　不了情暫撮土為香
     44 變生不測鳳姐潑醋　喜出望外平兒理妝
     45 金蘭契互剖金蘭語　風雨夕悶制風雨詞
     46 尷尬人難免尷尬事　鴛鴦女誓絕鴛鴦偶
     47 呆霸王調情遭苦打　冷郎君懼禍走他鄉
     48 濫情人情誤思游藝　慕雅女雅集苦吟詩
     49 琉璃世界白雪紅梅　脂粉香娃割腥啖膻
     50 蘆雪庵爭聯即景詩　暖香塢雅制春燈謎
     51 薛小妹新編懷古詩　胡庸醫亂用虎狼藥
     52 俏平兒情掩蝦鬚鐲　勇晴雯病補雀金裘
     53 寧國府除夕祭宗祠　國府元宵開夜宴
     54 史太君破陳腐舊套　王熙鳳效戲彩斑衣
     55 辱親女愚妾爭閑氣　欺幼主刁奴蓄險心
     56 敏探春興利除宿弊　時寶釵小惠全大體
     57 慧紫鵑情辭試忙玉　慈姨媽愛語慰痴顰
     58 杏子陰假鳳泣虛凰　茜紗窗真情揆痴理
     59 柳葉渚邊嗔鶯咤燕  絳雲軒裏召將飛符
     60 茉莉粉替去薔薇硝　玫瑰露引來茯苓霜
     61 投鼠忌器寶玉瞞贓　判冤決獄平兒行權
     62 憨湘雲醉眠芍藥裀　呆香菱情解石榴裙
     63 壽怡紅群芳開夜宴　死金丹獨艷理親喪
     64 幽淑女悲題五美吟　浪蕩子情遺九龍珮
     65 賈二舍偷娶尤二姨　尤三姐思嫁柳二郎
     66 情小妹恥情歸地府　冷二郎一冷入空門
     67 饋土物顰卿念故里　訊家童鳳姐蓄陰謀
     68 苦尤娘賺入大觀園　酸鳳姐大鬧寧國府
     69 弄小巧用借劍殺人　覺大限吞生金自逝
     70 林黛玉重建桃花社　史湘雲偶填柳絮詞
     71 嫌隙人有心生嫌隙　鴛鴦女無意遇鴛鴦
     72 王熙鳳恃強羞說病　來旺婦倚勢霸成親
     73 痴丫頭誤拾繡春囊　懦小姐不問纍金鳳
     74 惑奸讒抄檢大觀園　矢孤介杜絕寧國府
     75 開夜宴異兆發悲音　賞中秋新詞得佳讖
     76 凸碧堂品笛感淒清　凹晶館聯詩悲寂寞
     77 俏丫鬟抱屈夭風流　美優伶斬情歸水月
     78 老學士閑徵姽嫿詞　痴公子杜撰芙蓉誄
     79 薛文龍悔娶河東獅　賈迎春誤嫁中山狼
     80 懦弱迎春腸回九曲  姣怯香菱病入膏肓
     81 占旺相四美釣游魚　奉嚴詞兩番入家塾
     82 老學究講義警玩心　病瀟湘痴魂驚惡夢
     83 省宮闈賈元妃染恙　鬧閨閫薛寶釵吞聲
     84 試文字寶玉始提親　探驚風賈環重結怨
     85 賈存周報升郎中任　薛文起復惹放流刑
     86 受私賄老官翻案牘　寄閑情淑女解琴書
     87 感深秋撫琴悲往事　坐禪寂走火入邪魔
     88 博庭歡寶玉贊孤兒　正家法賈珍鞭悍僕
     89 人亡物在公子填詞　蛇影杯弓顰卿絕粒
     90 失綿衣貧女耐嗷嘈　送果品小郎驚叵測
     91 縱淫心寶蟾工設計　布疑陣寶玉妄談禪
     92 評女傳巧姐慕賢良　玩母珠賈政參聚散
     93 甄家僕投靠賈家門　水月庵掀翻風月案
     94 宴海棠賈母賞花妖　失寶玉通靈知奇禍
     95 因訛成實元妃薨逝　以假混真寶玉瘋顛
     96 瞞消息鳳姐設奇謀　洩機關顰兒迷本性
     97 林黛玉焚稿斷痴情　薛寶釵出閨成大禮
     98 苦絳珠魂歸離恨天　病神瑛淚灑相思地
     99 守官箴惡奴同破例　閱邸報老舅自擔驚
    100 破好事香菱結深恨　悲遠嫁寶玉感離情
    101 大觀園月夜感幽魂　散花寺神籤驚異兆
    102 寧國府骨肉病災祲　大觀園符水驅妖孽
    103 施毒計金桂自焚身　昧真禪雨村空遇舊
    104 醉金剛小鰍生大浪　痴公子餘痛觸前情
    105 錦衣軍查抄寧國府　驄馬使彈劾平安州
    106 王熙鳳致禍抱羞慚　賈太君禱天消禍患
    107 散餘資賈母明大義　復世職政老沐天恩
    108 強歡笑蘅蕪慶生辰　死纏綿瀟湘聞鬼哭
    109 候芳魂五兒承錯愛　還孽債迎女返真元
    110 史太君壽終歸地府　王鳳姐力詘失人心
    111 鴛鴦女殉主登太虛　狗彘奴欺天招夥盜
    112 活冤孽妙尼遭大劫　死讎仇趙妾赴冥曹
    113 懺宿冤鳳姐托村嫗　釋舊憾情婢感痴郎
    114 王熙鳳歷幻返金陵　甄應嘉蒙恩還玉闕
    115 惑偏私惜春矢素志　證同類寶玉失相知
    116 得通靈幻境悟仙緣　送慈柩故鄉全孝道
    117 阻超凡佳人雙護玉　欣聚黨惡子獨承家
    118 記微嫌舅兄欺弱女　驚謎語妻妾諫痴人
    119 中鄉魁寶玉卻塵緣　沐皇恩賈家延世澤
    120 甄士隱詳說太虛情　賈雨村歸結紅樓夢
# Japanese
    121 ミラ－が映し出す幻を氣にしながら
    122 いつの間にか速度上げてるのさ
    123 どこへ行ってもいいと言われると
    124 半端な願望には標識も全部灰色だ
    125
    126 炎の搖らめき　今宵も夢を描く
    127 あなたの筆先　渴いていませんか
    128
    129 青い空が見えぬなら青い傘廣げて
    130 いいじゃないかキャンバスは君のもの
    131 白い旗はあきらめた時にだけかざすの
    132 今は真っ赤に誘う鬥牛士のように
    133
    134 カラ－も色あせる螢光燈のおと
    135 白黑のチェスボ－ドの上で君に出會った
    136
    137 僕らは一時　迷いながら寄り添って
    138 あれから一月憶えていますか
    139
    140 オレンジ色の夕日を鄰で見てるだけで
    141 よかったのにな口は災いの元
    142
    143 黑い服は死者に祈る時にだけ著るの
    144 わざと真っ赤に殘したル－ジュの痕
    145
    146 もう自分には夢の無い繪しか描けないと言うなら
    147 塗り漬してよキャンバスを何度でも
    148 白い旗はあきらめた時にだけかざすの
    149 今の私はあなたの知らない色
# Simplified Chinese
    150 昔在黄帝，生而神灵，弱而能言，幼而徇齐，长而敦敏，成而登天。乃问于天师曰
    151 ：“余闻上古之人，春秋皆度百岁，而动作不衰；今时之人，年半百而动作皆衰者
    152 ，时世异耶？人将失之耶？”
    153 岐伯对曰：“上古之人，其知道者，法于阴阳，和于术数，食饮有节，起居有常，
    154 不妄作劳，故能形与神俱，而尽终其天年，度百岁乃去。今时之人不然也，以酒为
    155 浆，以妄为常，醉以入房，以欲竭其精，以耗散其真，不知持满，不时御神，务快
    156 其心，逆于生乐，起居无节，故半百而衰也。”
# Korean
    157 영화 '왕의 남자'(이준익 감독, 씨네월드 이글픽처스 공동제작)가 개봉 3주차를
    158 넘겨서도 지칠줄 모르는 흥행 돌풍을 이어가고 있다.
    159 '왕의 남자'는 지난 주말인 14~15일 서울 86개 스크린에서 23만 2082명을 끌어모
    160 았다. 이는 전 주말스코어 보다 2만 여명 늘어난 성적으로 지난주 개봉한 화제작
    161 '야수'를 두배가까이 앞서고 있다. '왕의 남자' 는 15일까지 전국 누계 475만
    162 2000명(389개 스크린)으로 17일 500만 관객 돌파가 예상된다. 
# Deutsch
    163 Mißhör mich nicht, du holdes Angesicht!  Wer darf ihn nennen Und wer
    164 bekennen: Ich glaub' ihn.  Wer empfinden Und sich überwinden Zu sagen:
    165 ich glaub ihn nicht!  Der Allumfasser, Der Allerhalter, Faßt und erhält
    166 er nicht Dich, mich, sich selbst?  Wölbt sich der Himmel nicht dadroben? 
    167 Liegt die Erde nicht hierunten fest?  Und steigen freundlich blickend
    168 Ewige Sterne nicht herauf?  Schau ich nicht Aug in Auge dir, Und drängt
    169 nicht alles Nach Haupt und Herzen dir Und webt in ewigem Geheimnis
    170 Unsichtbar-sichtbar neben dir?  Erfüll davon dein Herz, so groß es ist,
    171 Und wenn du ganz in dem Gefühle selig bist, Nenn es dann, wie du willst:
    172 Nenns Glück! Herz! Liebe! Gott!  Ich habe keinen Namen Dafür! Gefühl ist
    173 alles; Name ist Schall und Rauch, Umnebelnd Himmelsglut.
