
$file_dir = './STFiles/'
$deck_dir = './STDecks/'
$pic_dir = './STPics/'
$pic_type = ".jpg"
$port = 7824 #STCG on phone pad
$: << $file_dir
#$stdout = $stderr = File.new("stclient.log", "w")

require 'yaml'
require 'dialogs'
require 'interface'
require 'fox16'
require 'drb'
require 'socket'
include Fox


class STCCG
	def initialize
		#Make the app
		theApp = FXApp.new
		
		#Create the interface
		interface = Interface.new(theApp, "STCCG v0.1")
		dialog = JoinDialogBox.new(interface)
		#Create the app, show the main window, and run the app
		theApp.create
		dialog.show
		interface.show
    theApp.run
  end
end

if $0 == __FILE__
  #Start a game
  STCCG.new
end