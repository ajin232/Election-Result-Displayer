//
//  ContentView.swift
//  Election Result Displayer
//
//  Created by Andrew on 5/26/25.
//
//  using semicolons for aesthetic purposes
//  using explicit type declarations because type inference is a disgusting abomination

import Foundation;
import SwiftUI;
import AVKit;

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>;
    @State private var showAlert: Bool = true;
    @StateObject var googleraces: ElectionData = ElectionData();
    @StateObject var localraces: ElectionData = ElectionData();
    @StateObject var manualrace: RaceString = RaceString(racename: "Enter name", index: 0, demname: "", dempercent: "", demvotes: "", dempic: "", gopname: "", goppercent: "", gopvotes: "", goppic: "", winner: "N");
    @EnvironmentObject var current: CurrentRace;
    var body: some View {
        ZStack{
            NSVideoPlayer();
            Image("templatebacking").resizable().aspectRatio(contentMode: .fit).frame(width: 1280, height: 720, alignment: .center);
            AsyncImage(url: URL(string: current.race.dempic)){ result in
                result.image?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 310, height: 280)
                    .clipped();
            }.frame(width: 310, height: 280).position(x: 310, y: 360);
            AsyncImage(url: URL(string: current.race.goppic)){ result in
                result.image?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 310, height: 280)
                    .clipped();
            }.frame(width: 310, height: 280).position(x: 970, y: 360);
            Image("templatesf").resizable().aspectRatio(contentMode: .fit).frame(width: 1280, height: 720, alignment: .center)
//                .alert(isPresented: $showAlert, content: {
//                    Alert(title: Text("Information"),
//                          message: Text("To input data to be displayed, go to the menu bar, then File -> Open Control Panel"),
//                          dismissButton: Alert.Button.default(
//                                  Text("OK"), action: {
//                                     showAlert = false
//                        })
//                    )
//                });
            Text(current.race.racename).font(.system(size: 34, weight: .semibold)).frame(maxWidth: 638, maxHeight: 50).position(x: 640, y: 123).foregroundColor(.black);
            Text(current.race.demname).font(.system(size: 29)).multilineTextAlignment(.center).foregroundStyle(.white).frame(maxWidth: 310, maxHeight: 40).position(x: 311, y: 526);
            Text(current.race.gopname).font(.system(size: 29)).multilineTextAlignment(.center).foregroundStyle(.white).frame(maxWidth: 310, maxHeight: 40).position(x: 971, y: 526);
            Text(String(current.race.demvotes) + " votes").font(.title).fontWeight(.semibold).foregroundColor(Color(red: 0.1607843137254902, green: 0.5019607843137255, blue: 0.7254901960784313)).multilineTextAlignment(.leading).frame(maxWidth: 240, maxHeight: 35, alignment: .leading).position(x: 286, y: 580);
            Text(String(current.race.dempercent) + "%").font(.title).foregroundColor(Color(red: 0.1607843137254902, green: 0.5019607843137255, blue: 0.7254901960784313)).multilineTextAlignment(.leading).frame(maxWidth: 240, maxHeight: 35, alignment: .leading).position(x: 286, y: 610);
            Text(String(current.race.gopvotes) + " votes").font(.title).fontWeight(.semibold).foregroundColor(Color(red: 0.7529411764705882, green: 0.2235294117647059, blue: 0.16862745098039217)).multilineTextAlignment(.leading).frame(maxWidth: 240, maxHeight: 35, alignment: .leading).position(x: 946, y: 580);
            Text(String(current.race.goppercent) + "%").font(.title).foregroundColor(Color(red: 0.7529411764705882, green: 0.2235294117647059, blue: 0.16862745098039217)).multilineTextAlignment(.leading).frame(maxWidth: 240, maxHeight: 35, alignment: .leading).position(x: 946, y: 610);
            if current.race.winner == "D"{
                Image(systemName: "checkmark").position(x: 440, y: 595).font(.system(size: 34)).foregroundColor(Color(red: 0.9451, green: 0.7686, blue: 0.0589));
            } else if current.race.winner == "R" {
                Image(systemName: "checkmark").position(x: 1100, y: 595).font(.system(size: 34)).foregroundColor(Color(red: 0.9451, green: 0.7686, blue: 0.0589));
            }
        }.frame(minWidth: 1280, maxWidth: 1280, minHeight: 720, maxHeight: 720);
        
        
    }
}

struct PanelView: View{
    @State var selection: Int = 0;
    @ObservedObject var googleraces: ElectionData;
    @ObservedObject var localraces: ElectionData;
    @ObservedObject var manualrace: RaceString;
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: 0) {
                    Label("Google Sheets input", systemImage: "arrow.down.doc.fill")
                        .font(.title3);
                }.padding(.top, 4).padding(.bottom, 4);
                NavigationLink(value: 1) {
                    Label("Local CSV input", systemImage: "internaldrive.fill")
                        .font(.title3);
                }.padding(.top, 4).padding(.bottom, 4);
                NavigationLink(value: 2) {
                    Label("Manual input", systemImage: "keyboard.fill")
                        .font(.title3);
                }.padding(.top, 4).padding(.bottom, 4);
                NavigationLink(value: 3) {
                    Label("Background", systemImage: "photo.tv")
                        .font(.title3);
                }.padding(.top, 4).padding(.bottom, 4);
                NavigationLink(value: 4) {
                    Label("Help", systemImage: "questionmark.circle")
                        .font(.title3);
                }.padding(.top, 4).padding(.bottom, 4);
            }
            .navigationSplitViewColumnWidth(200);
        } detail: {
            switch selection{
            case 1:
                localView(races: localraces);
            case 2:
                manualView(selection: manualrace);
            case 3:
                settingsView();
            case 4:
                helpView();
            default:
                importGoogleView(races: googleraces);
            }
        }
        .frame(minWidth: 800, maxWidth: 800, minHeight: 500, maxHeight: 500);
        
    }
}

struct importGoogleView: View{
    @State var address: String = "";
    @State var disabled1: Bool = false;
    @State var disabled2: Bool = true;
    @State var task: Task<(), any Error>?;
    @State var selection: Race?;
    @ObservedObject var races: ElectionData;
    @EnvironmentObject var current: CurrentRace;
    var body: some View{
        VStack(alignment: .leading){
            GroupBox(label:
                        Label("Import input from Google Sheets", systemImage: "arrow.down.doc.fill").font(.title2)
            ) {
                Form{
                    HStack{
                        TextField(text: $address, prompt: Text("Google sheets link (make sure it is public)")) {
                            Text("Address");
                        }
                        Button(action: {
                            var result: String = "";
                            task = Task{
                                disabled2 = false;
                                disabled1 = true;
                                do{
                                    try await result = fetchSheets(address);
                                    var temp: Array<Race> = [Race]();
                                    let returncode: Int = parseCSVString(pointer: &temp, string: result);
                                    print(result);
                                    if returncode == 1{
                                        throw AppError.fetchError("csv has no data");
                                    }
                                    races.replace(with: temp);
                                } catch {
                                    print(error);
                                }
                                disabled1 = false;
                                disabled2 = true;
                            }
                        }, label: {
                            Text("Fetch");
                        }).disabled(disabled1);
                        
                        Button(action: {
                            print(task?.isCancelled);
                            task?.cancel();
                            print(task?.isCancelled);
                            disabled1 = false;
                            disabled2 = true;
                        }, label: {
                            Text("Cancel");
                        }).disabled(disabled2);
                    }
                    
                }
                .disableAutocorrection(true);
                List(selection: $selection, content: {
                    ForEach(races.data, id: \.self) { elem in
                        Text(elem.menuname);
                    }
                });
                Text("You can also use the ↑ and ↓ arrow keys to navigate the list, and the return key to display.");
                Button(action: {
                    print(selection);
                    if selection != nil{
                        current.replace(selection!);
                    }
                }, label: {
                    Text("Display").font(.title2).padding().frame(maxWidth: .infinity);
                }).buttonStyle(.bordered).keyboardShortcut(.defaultAction);
            }
        }.frame(maxWidth: 800, maxHeight: 500, alignment: .topLeading).padding(12);
        
    }
}

struct localView: View{
    @State var pathstring: String = "";
    @State var csvpath: URL?;
    @State var showfinder: Bool = false;
    @State var selection: Race?;
    @State var disabled: Bool = true;
    @ObservedObject var races: ElectionData;
    @EnvironmentObject var current: CurrentRace;
    var body: some View{
        VStack(alignment: .leading){
            GroupBox(label:
                        Label("Import input from CSV file on this computer", systemImage: "internaldrive.fill").font(.title2)
            ) {
                Form{
                    HStack{
                        TextField(text: $pathstring, prompt: Text(".csv files only")) {
                            Text("File path");
                        }.disabled(true);
                        Button(action: {
                            showfinder = true;
                        }, label: {
                            Text("Choose file");
                        })
                        .fileImporter(isPresented: $showfinder, allowedContentTypes: [UTType.commaSeparatedText], onCompletion: { result in
                            switch result{
                            case .success(let path):
                                csvpath = path;
                                pathstring = path.absoluteString;
                                print(csvpath);
                                disabled = false;
                                print(path);
                            case .failure(let error):
                                disabled = true;
                                print(error);
                            }
                        })
                        Button(action: {
                            do{
                                guard csvpath!.startAccessingSecurityScopedResource() else {
                                    throw AppError.fetchError("file access denied")
                                }
                                let result: String = try String(contentsOf: csvpath!);
                                csvpath!.stopAccessingSecurityScopedResource();
                                var temp: Array<Race> = [Race]();
                                let returncode: Int = parseCSVString(pointer: &temp, string: result);
                                print(result);
                                if returncode == 1{
                                    throw AppError.fetchError("csv has no data");
                                }
                                races.replace(with: temp);
                            } catch {
                                print(error);
                            }
                        }, label: {
                            Text("Read selected file");
                        }).disabled(disabled);
                    }
                    
                }
                .disableAutocorrection(true);
                List(selection: $selection, content: {
                    ForEach(races.data, id: \.self) { elem in
                        Text(elem.menuname);
                    }
                });
                Text("You can also use the ↑ and ↓ arrow keys to navigate the list, and the return key to display.");
                Button(action: {
                    print(selection);
                    if selection != nil{
                        current.replace(selection!);
                    }
                }, label: {
                    Text("Display").font(.title2).padding().frame(maxWidth: .infinity);
                }).buttonStyle(.bordered).keyboardShortcut(.defaultAction);
            }
        }.frame(maxWidth: 800, maxHeight: 500, alignment: .topLeading).padding(12);
        
    }
}

struct manualView: View{
    @State var test: String = "";
    @ObservedObject var selection: RaceString;
    let example: RaceString = RaceString(racename: "Enter name", index: 0, demname: "", dempercent: "", demvotes: "", dempic: "", gopname: "", goppercent: "", gopvotes: "", goppic: "", winner: "N");
    @EnvironmentObject var current: CurrentRace;
    var body: some View{
        VStack(alignment: .leading){
            GroupBox(label:
                        Label("Manual input", systemImage: "keyboard.fill").font(.title2)
            ) {
                Form{
                    TextField(text: $selection.racename, prompt: Text("")) {
                        Text("Title of race");
                    }
                }
                Text("");
                Form{
                    VStack(alignment: .leading){
                        HStack{
                            Text("Democrat    ");
                            TextField(text: $selection.demname, prompt: Text("")) {
                                Text("Name");
                            }
                            TextField(text: $selection.dempercent, prompt: Text("")) {
                                Text("%");
                            }
                            TextField(text: $selection.demvotes, prompt: Text("")) {
                                Text("Votes");
                            }
                        }
                        TextField(text: $selection.dempic, prompt: Text("")) {
                            Text("                       Picture Link");
                        }
                        HStack{
                            Text("Republican  ");
                            TextField(text: $selection.gopname, prompt: Text("")) {
                                Text("Name");
                            }
                            TextField(text: $selection.goppercent, prompt: Text("")) {
                                Text("%");
                            }
                            TextField(text: $selection.gopvotes, prompt: Text("")) {
                                Text("Votes");
                            }
                        }
                        TextField(text: $selection.goppic, prompt: Text("")) {
                            Text("                       Picture Link");
                        }
                        Picker("Winner         ", selection: $selection.winner){
                            Text("Democrat").tag("D");
                            Text("Republican").tag("R");
                            Text("Neither").tag("N");
                        }.pickerStyle(.segmented);
                        Text("");
                    }
                }
                Button(action: {
                    print(selection);
                    if selection != example{
                        selection.index = 1;
                        if (selection.convert() != nil){
                            current.replace(selection.convert()!);
                        }
                    }
                }, label: {
                    Text("Display").font(.title2).padding().frame(maxWidth: .infinity);
                }).buttonStyle(.bordered).keyboardShortcut(.defaultAction);
            }
        }.frame(maxWidth: 800, maxHeight: 500, alignment: .topLeading).padding(12);
    }
}

struct settingsView: View{
    var body: some View{
        Text("ability to change background video has yet to be implemented");
    }
}

struct helpView: View{
    @Environment(\.openURL) var openURL;
    let template: Data = "RACE NAME,DEM NAME,DEM %,DEM VOTES,DEM PICTURE,GOP NAME,GOP %,GOP VOTES,GOP PICTURE,WINNER(D/R/N)\n(EXAMPLE) 2016 Presidential Election,Hillary Clinton,48.2,65853514,https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQtbIYfy2wkMMfWrW7-31tnVI8gE0Iz4HhqHufpIToSVjcjWC_Gq9A4cHxSK8a-3makZxwlAfnlJyOeJW4OHj9rwg,Donald Trump,46.1,62984828,https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Donald_Trump_official_portrait.jpg/250px-Donald_Trump_official_portrait.jpg,R".data(using: .utf8)!;
    var body: some View{
        VStack(alignment: .leading){
            GroupBox(label:
                        Label("Help", systemImage: "questionmark.circle").font(.title2)) 
            {
                ScrollView(.vertical){
                    VStack(alignment: .leading){
                        Text("CSV file template").font(.title3).fontWeight(.semibold);
                        Text("If you are importing your input from Google Sheets or from a local csv file, use this information to get started. This app is designed to take input from a csv file that is formatted in a predetermined, specific way. That specific format is:");
                        Text("• Each election race is represented by a row, starting from the second row");
                        Text("• The top (first) row is either left blank or is labelled with which value each column represents")
                        Text("• The columns should be represented by the values in this order:");
                        Text("• Name of the race, Name of the Democrat, Democrat vote percent, Democrat vote count, Link to a picture of the Democrat, Name of the Republican, Republican vote percent, Republican vote count, Link to a picture of the Republican, Who the winner is (D for Democrat/R for Republican/N for neither)\n");
                        Text("Press the button below to view and download a premade template file");
                        Button(action: {
                            openURL(URL(string: "https://github.com/ajin232/Election-Result-Displayer/blob/main/Election%20Result%20Displayer/template.csv")!);
                        }, label: {
                            Text("Open template download webpage");
                        }).buttonStyle(.borderedProminent);
                        Image("downloadlink").resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 300);
                        Text("Once you have created the template file, you can use it for either the Google Sheets input tab or the Local CSV input tab. For more information on those tabs, you can read their respective sections in this help guide.\n");
                        Text("Warning about commas").font(.title3).fontWeight(.semibold);
                        Text("DO NOT TYPE COMMAS INTO YOUR SPREADSHEET!").fontWeight(.semibold);
                        Text("The app will not be able to read your data if you do. This is because of the nature of csv files. The name csv stands for **comma-seperated values**, which means that boundaries of the cells are delineated by commas. That means that if you type a comma in the middle of a cell (e.g. typing \"Al Gore, Jr.\" instead of \"Al Gore Jr.\"), the program will think that that cell is two different cells.\n");
                        Text("Information about number formatting").fontWeight(.semibold);
                        Text("Sometimes, Excel or Sheets will force numbers to be formatted with commas (e.g. 123,456 instead of 123456), and this will cause problems. Here is how to fix a cell where commas are being forced into the numbers:\n");
                        Text("**In Excel:** Right click on the cell -> **Format Cells...** -> In the **Number** tab, look for the **Category** box and click **General** -> **OK**\n");
                        Text("**In Google Sheets:** Click on the cell -> Go to the menu bar and click **Format** -> **Number** -> **Plain Text**\n");
                        Text("Google Sheets input instructions").font(.title3).fontWeight(.semibold);
                        Text("First, download the template csv file (or create your own in the format specified above).");
                        Text("Then, upload that file to your Google Drive, and open it in Google Sheets. You can now start entering data.");
                        Text("To connect the spreadsheet to the app, click the **Share** button in Google Sheets and create a link where **anyone with the link** can access the document.");
                        Text("Then, copy that link and paste it into the Google Sheets input tab in the app, and press the **Fetch** button. You should now be able to see the election races listed in the app.");
                        Text("You can now select any election race you want to present, and then present it by clicking the **Display** button at the bottom of the app.");
                        Text("To refresh the information after the spreadsheet has been updated, you can simply click the **Fetch** button again.");
                        Text("If you press the fetch button and the app hangs, it is probably an internet connection problem, or you may have entered an invalid link. In this case, click the **Cancel** button and try again.\n");
                        Text("Local CSV file input instructions").font(.title3).fontWeight(.semibold);
                        Text("First, download the template csv file (or create your own in the format specified above).");
                        Text("Then, open that file with Microsoft Excel and start entering data.");
                        Text("To connect the file to the app, click the **Choose file** button in the Local CSV input tab, and navigate to where you saved your file. Then, once you have selected your file, click the **Read selected file** button.");
                        Text("You can now select any election race you want to present, and then present it by clicking the **Display** button at the bottom of the app.");
                        Text("To refresh the information after the spreadsheet has been updated, you can simply click the **Fetch** button again.");
                        Text("If you run into an error, check the formatting of your file, or restart the app.\n");
                        Text("Manual input instructions").font(.title3).fontWeight(.semibold);
                        Text("This part of the app should be self explanatory. Also, the no-commas rule still holds.\n");
                    }
                }.frame(maxWidth: 800, alignment: .topLeading);
            }
        }.frame(maxWidth: 800, maxHeight: 500, alignment: .topLeading).padding(12);
    }
}

struct NSVideoPlayer: NSViewRepresentable {
    func makeNSView(context: Context) -> AVPlayerView {
        let url = Bundle.main.url(forResource: "stars", withExtension: "mp4");
        let item = AVPlayerItem(url: url!);
        let queue = AVQueuePlayer(playerItem: item);
        context.coordinator.looper = AVPlayerLooper(player: queue, templateItem: item);
        
        let view = AVPlayerView();
        view.player = queue;
        view.controlsStyle = .none;
        view.player?.playImmediately(atRate: 1);
        return view;
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator();
    }
    
    class Coordinator {
        var looper: AVPlayerLooper? = nil;
    }
}

enum AppError: Error {
    case fetchError(String);
}

#Preview {
    //PanelView(googleraces: ElectionData(data: [Race]())).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext);
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext).environmentObject(CurrentRace());
}
