
$file_dir = './STFiles/'
$deck_dir = './STDecks/'
$pic_dir = './STPics/'
$pic_type = ".jpg"
$port = 7824 #STCG on phone pad
$uri = "druby://127.0.0.1:7824"
$: << $file_dir
#$stdout = $stderr = File.new("stserver.log", "w")

require 'yaml'
require 'card'
require 'server'
require 'game'
require 'player'
require 'stack'
require 'drb'
require 'fox16'
include Fox


$AFFILIATIONS = [:alpha, :gamma, :delta, :alternate, :ds9, 
:earth, :maquis, :terok_nor, :tng, :command, :staff,
:bajoran, :borg, :cardassian, :dominion, :federation, 
:ferengi, :klingon, :non_aligned, :romulan]

$KEYWORDS = [:admiral, :alpha, :artifact, :assassin, :assault,
:bajoran_resistance, :cadet, :capture, :chancellor, :cloaking_device,
:commander, :consume, :crime, :dabo_girl, :decay, :dissident, :drone,
:founder, :gatherer, :general, :genetically_enhanced, :glinn, :gul,
:hand_weapon, :high_council_member, :host, :legate, :maneuver,
:morph, :nebula, :pah_wraith, :praetor, :prophet, :prylar, :punishment,
:pursuit, :q, :region, :replicate, :rule, :senator, :shape_shifter,
:smuggler, :temporal, :thief, :vedek, :waiter]

$SKILLS = [:acquisition, :anthropology, :archaeology,
:astrometrics, :biology, :diplomacy, :engineer, :exobiology,
:geology, :honor, :intelligence, :law, :leadership, :medical,
:navigation, :officer, :physics, :programming, :science,
:security, :telepathy, :transporters, :treachery]

$SPECIES = [:acamarian, :alien, :alien_human, :andorian,
:android, :angosian, :atrean, :bajoran, :bajoran_cardassian,
:barzan, :benzite, :betazoid, :betazoid_human, :bolian,
:borg, :cairn, :cardassian, :chameloid, :changeling, :denobulan,
:el_aurian, :farian, :ferengi, :flaxian, :hekaran, :hologram,
:human, :human_alien, :human_klingon, :human_napean,
:human_vulcan, :hupyrian, :idanian, :jemhadar,
:kellerun, :klingon, :kobliad, :kriosian, :ktarian, :lethean,
:lurian, :markalian, :ocampa, :orion, :pakled, :ramatin,
:reman, :romulan, :satarran, :solari, :suliban, :tlani,
:takaran, :talaxian, :tamarian, :tanugan, :tiburonian,
:tosk, :trill, :ullian, :ventaxian, :vorta, :vulcan,
:yridian, :zalkonian, :zibalian]


if $0 == __FILE__
  #BEGIN{GC.disable}
  #END{GC.enable; GC.start}
  theApp = FXApp.new
  $server = STCCGServer.new(theApp, "Star Trek CCG GameServer")
  thr = Array.new
  thr << Thread.new do	
    theApp.create
    $server.show
    theApp.run
  end
  DRb.start_service($uri, $server.game)
  thr << DRb.thread
  thr.each{|thread| thread.join}
end
