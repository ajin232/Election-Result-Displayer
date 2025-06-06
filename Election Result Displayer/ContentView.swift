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
    // main window
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
            // background animation
            NSVideoPlayer();
            // back of candidate frames + shadows underneath frames
            Image("templatebacking").resizable().aspectRatio(contentMode: .fit).frame(width: 1280, height: 720, alignment: .center);
            // democrat and republican candidate photos
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
            // main graphics layout image
            Image("templatesf").resizable().aspectRatio(contentMode: .fit).frame(width: 1280, height: 720, alignment: .center)
                .alert(isPresented: $showAlert, content: { // info popup at start
                    Alert(title: Text("Information"),
                          message: Text("To input data to be displayed, go to the menu bar, then File -> Open Control Panel"),
                          dismissButton: Alert.Button.default(
                                  Text("OK"), action: {
                                     showAlert = false
                        })
                    )
                });
            // title of election race being displayed
            Text(current.race.racename).font(.system(size: 35, weight: .semibold)).frame(maxWidth: 640, maxHeight: 50).position(x: 640, y: 123).foregroundColor(.black);
            // names/vote counts/percents of the candidates
            Text(current.race.demname).font(.system(size: 29)).multilineTextAlignment(.center).foregroundStyle(.white).frame(maxWidth: 310, maxHeight: 40).position(x: 311, y: 526);
            Text(current.race.gopname).font(.system(size: 29)).multilineTextAlignment(.center).foregroundStyle(.white).frame(maxWidth: 310, maxHeight: 40).position(x: 971, y: 526);
            Text(String(current.race.demvotes.formatted(.number)) + " votes").font(.title).fontWeight(.semibold).foregroundColor(Color(red: 0.1607843137254902, green: 0.5019607843137255, blue: 0.7254901960784313)).multilineTextAlignment(.leading).frame(maxWidth: 240, maxHeight: 35, alignment: .leading).position(x: 286, y: 580);
            Text(String(current.race.dempercent) + "%").font(.title).foregroundColor(Color(red: 0.1607843137254902, green: 0.5019607843137255, blue: 0.7254901960784313)).multilineTextAlignment(.leading).frame(maxWidth: 240, maxHeight: 35, alignment: .leading).position(x: 286, y: 610);
            Text(String(current.race.gopvotes.formatted(.number)) + " votes").font(.title).fontWeight(.semibold).foregroundColor(Color(red: 0.7529411764705882, green: 0.2235294117647059, blue: 0.16862745098039217)).multilineTextAlignment(.leading).frame(maxWidth: 240, maxHeight: 35, alignment: .leading).position(x: 946, y: 580);
            Text(String(current.race.goppercent) + "%").font(.title).foregroundColor(Color(red: 0.7529411764705882, green: 0.2235294117647059, blue: 0.16862745098039217)).multilineTextAlignment(.leading).frame(maxWidth: 240, maxHeight: 35, alignment: .leading).position(x: 946, y: 610);
            // checkmark for winner if there is a winner among the two
            if current.race.winner == "D"{
                Image(systemName: "checkmark").position(x: 440, y: 595).font(.system(size: 34)).foregroundColor(Color(red: 0.9451, green: 0.7686, blue: 0.0589));
            } else if current.race.winner == "R" {
                Image(systemName: "checkmark").position(x: 1100, y: 595).font(.system(size: 34)).foregroundColor(Color(red: 0.9451, green: 0.7686, blue: 0.0589));
            }
        }.frame(minWidth: 1280, maxWidth: 1280, minHeight: 720, maxHeight: 720);
    }
}

struct PanelView: View{
    // basis of the control panel window
    @State var selection: Int = 0;
    @ObservedObject var googleraces: ElectionData;
    @ObservedObject var localraces: ElectionData;
    @ObservedObject var manualrace: RaceString;
    var body: some View {
        // navigation sidebar in control panel
        NavigationSplitView {
            // menu sets the value of the variable "selection"
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
            // remainder of the window displays the tab that was selected, according to the "selection" variable
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
    // google sheets input tab
    @State var address: String = "";
    @State var disabled1: Bool = false;
    @State var disabled2: Bool = true;
    @State var task: Task<(), any Error>?;
    @State var selection: Race?;
    @State var infotext: String = "Do not type commas into your spreadsheet. See more info in the Help tab. ";
    @ObservedObject var races: ElectionData;
    @EnvironmentObject var current: CurrentRace;
    let defaultinfo: String = "Do not type commas into your spreadsheet. See more info in the Help tab. ";
    var body: some View{
        VStack(alignment: .leading){
            GroupBox(label:
                        Label("Import input from Google Sheets", systemImage: "arrow.down.doc.fill").font(.title2)
            ) {
                Form{
                    HStack{
                        // web address input field
                        TextField(text: $address, prompt: Text("Google sheets link (make sure it is public)")) {
                            Text("Address");
                        }
                        // fetch data/refresh button
                        Button(action: {
                            var result: String = ""; // csv data will be fed into this string
                            // start async fetching task
                            task = Task{
                                // while task is running, disable fetch button and enable cancel button
                                disabled2 = false;
                                disabled1 = true;
                                do{
                                    // try to download csv based on the inputted link and feed it into "result" string
                                    // fetchSheets function is in ProcessCSV.swift, will throw error if link is wrong or not working
                                    try await result = fetchSheets(address);
                                    // if successful, try to parse the string into custom "race" format
                                    var temp: Array<Race> = [Race]();
                                    let returncode: Int = parseCSVString(pointer: &temp, string: result); // returns 0 if no error
                                    //print(result);
                                    if returncode == 1{
                                        throw AppError.fetchError("file has no data");
                                    } else if returncode == 2{
                                        infotext = defaultinfo + "WARNING: at least one row in the spreadsheet is invalid";
                                    }
                                    // replace existing (if any) list of election races with the new ones that were just fetched
                                    races.replace(with: temp);
                                    // clear any error messages from infotext
                                    if returncode == 0{
                                        infotext = defaultinfo;
                                    }
                                } catch AppError.fetchError(let message){
                                    // if there was an error, print error to console and try to display it in infotext
                                    print(message);
                                    infotext = defaultinfo + "ERROR: " + message;
                                } catch{
                                    infotext = defaultinfo + "ERROR: unknown error";
                                }
                                // now that the task is done, disable the cancel button and enable the fetch button again
                                disabled1 = false;
                                disabled2 = true;
                            }
                        }, label: {
                            Text("Fetch");
                        }).disabled(disabled1);
                        // cancel button
                        Button(action: {
                            // halt fetch task if it is running
                            task?.cancel();
                            //print(task?.isCancelled);
                            // reset buttons back to default
                            disabled1 = false;
                            disabled2 = true;
                        }, label: {
                            Text("Cancel");
                        }).disabled(disabled2);
                    }
                    
                }
                .disableAutocorrection(true);
                // display info and potential errors
                Text(infotext);
                // display list of election races that have been fetched from spreadsheet
                List(selection: $selection, content: {
                    ForEach(races.data, id: \.self) { elem in
                        Text(elem.menuname);
                    }
                });
                Text("You can also use the ↑ and ↓ arrow keys to navigate the list, and the return key to display.");
                // display button
                Button(action: {
                    //print(selection);
                    if selection != nil{
                        // replace the current race being displayed with the one that was selected
                        current.replace(with: selection!);
                    }
                }, label: {
                    Text("Display").font(.title2).padding().frame(maxWidth: .infinity);
                }).buttonStyle(.bordered).keyboardShortcut(.defaultAction);
            }
        }.frame(maxWidth: 800, maxHeight: 500, alignment: .topLeading).padding(12);
    }
}

struct localView: View{
    // local csv input tab
    @State var pathstring: String = "";
    @State var csvpath: URL?;
    @State var showfinder: Bool = false;
    @State var selection: Race?;
    @State var disabled: Bool = true;
    @State var infotext: String = "Do not type commas into your spreadsheet. See more info in the Help tab. ";
    @ObservedObject var races: ElectionData;
    @EnvironmentObject var current: CurrentRace;
    let defaultinfo: String = "Do not type commas into your spreadsheet. See more info in the Help tab. ";
    var body: some View{
        VStack(alignment: .leading){
            GroupBox(label:
                        Label("Import input from a CSV file on this computer", systemImage: "internaldrive.fill").font(.title2)
            ) {
                Form{
                    HStack{
                        // file selection fields
                        TextField(text: $pathstring, prompt: Text(".csv files only")) {
                            Text("File path");
                        }.disabled(true); // dont let user type in file path manually, route them through finder window instead
                        // choose file button
                        Button(action: {
                            showfinder = true;
                        }, label: {
                            Text("Choose file");
                        })
                        .fileImporter(isPresented: $showfinder, allowedContentTypes: [UTType.commaSeparatedText], onCompletion: { result in
                            // when choose file button is clicked, open finder window to let user select csv file
                            switch result{
                            case .success(let path):
                                // file path formed successfully
                                csvpath = path;
                                pathstring = path.absoluteString;
                                //print(csvpath);
                                disabled = false;
                                infotext = defaultinfo;
                                //print(path);
                            case .failure(let error):
                                disabled = true;
                                infotext = defaultinfo + "ERROR: invalid file or file path";
                                print(error);
                            }
                        })
                        // read (open) file button
                        Button(action: {
                            do{
                                // request file access permissions if necessary
                                guard csvpath!.startAccessingSecurityScopedResource() else {
                                    // if user denies permission, throw error
                                    throw AppError.fetchError("file access denied")
                                }
                                // try to feed file contents into "result" string
                                let result: String = try String(contentsOf: csvpath!);
                                // once csv data has been copied, inform macos that file access is no longer needed
                                csvpath!.stopAccessingSecurityScopedResource();
                                // if successful, try to parse the string into custom "race" format
                                var temp: Array<Race> = [Race]();
                                let returncode: Int = parseCSVString(pointer: &temp, string: result); // returns 0 if no error
                                //print(result);
                                if returncode == 1{
                                    throw AppError.fetchError("file has no data");
                                } else if returncode == 2{
                                    infotext = defaultinfo + "WARNING: at least one row in the spreadsheet is invalid";
                                }
                                // replace existing (if any) list of election races with the new ones that were just fetched
                                races.replace(with: temp);
                                // clear any error messages from infotext
                                if returncode == 0{
                                    infotext = defaultinfo;
                                }
                            } catch AppError.fetchError(let message){
                                // if there was an error, print error to console and try to display it in infotext
                                print(message);
                                infotext = defaultinfo + "ERROR: " + message;
                            } catch{
                                infotext = defaultinfo + "ERROR: unknown error"
                            }
                        }, label: {
                            Text("Read selected file");
                        }).disabled(disabled);
                    }
                    
                }
                .disableAutocorrection(true);
                // display info and potential errors
                Text(infotext);
                // display list of election races that have been fetched from spreadsheet
                List(selection: $selection, content: {
                    ForEach(races.data, id: \.self) { elem in
                        Text(elem.menuname);
                    }
                });
                Text("You can also use the ↑ and ↓ arrow keys to navigate the list, and the return key to display.");
                // display button
                Button(action: {
                    //print(selection);
                    if selection != nil{
                        // replace the current race being displayed with the one that was selected
                        current.replace(with: selection!);
                    }
                }, label: {
                    Text("Display").font(.title2).padding().frame(maxWidth: .infinity);
                }).buttonStyle(.bordered).keyboardShortcut(.defaultAction);
            }
        }.frame(maxWidth: 800, maxHeight: 500, alignment: .topLeading).padding(12);
    }
}

struct manualView: View{
    // manual input tab
    @State var test: String = "";
    @ObservedObject var selection: RaceString;
    let example: RaceString = RaceString(racename: "Enter name", index: 0, demname: "", dempercent: "", demvotes: "", dempic: "", gopname: "", goppercent: "", gopvotes: "", goppic: "", winner: "N");
    @EnvironmentObject var current: CurrentRace;
    var body: some View{
        VStack(alignment: .leading){
            GroupBox(label:
                        Label("Manual input", systemImage: "keyboard.fill").font(.title2)
            ) {
                // data input fields
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
                }.disableAutocorrection(true);
                // display button
                Button(action: {
                    //print(selection);
                    if selection != example{ // if the data isn't the default placeholder data...
                        selection.index = 1;
                        if (selection.convert() != nil){ // and the data is formatted correctly...
                            // then replace the current race being displayed with the one that was inputted
                            current.replace(with: selection.convert()!);
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
    // change background tab (incomplete)
    var body: some View{
        Text("ability to change background video has yet to be implemented");
    }
}

struct helpView: View{
    // help tab
    @Environment(\.openURL) var openURL;
    let template: Data = "RACE NAME,DEM NAME,DEM %,DEM VOTES,DEM PICTURE,GOP NAME,GOP %,GOP VOTES,GOP PICTURE,WINNER(D/R/N)\n(EXAMPLE) 2016 Presidential Election,Hillary Clinton,48.2,65853514,https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQtbIYfy2wkMMfWrW7-31tnVI8gE0Iz4HhqHufpIToSVjcjWC_Gq9A4cHxSK8a-3makZxwlAfnlJyOeJW4OHj9rwg,Donald Trump,46.1,62984828,https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Donald_Trump_official_portrait.jpg/250px-Donald_Trump_official_portrait.jpg,R".data(using: .utf8)!;
    var body: some View{
        VStack(alignment: .leading){
            GroupBox(label:
                        Label("Help", systemImage: "questionmark.circle").font(.title2)) 
            {
                ScrollView(.vertical){
                    // just a bunch of text in a scrollable box
                    VStack(alignment: .leading){
                        Text("CSV file template").font(.title3).fontWeight(.semibold);
                        Text("If you are importing your input from Google Sheets or from a local csv file, use this information to get started. This app is designed to take input from a csv file that is formatted in this specific way:");
                        Text("• Each election race is represented by a row, starting from the second row");
                        Text("• The top (first) row is either left blank or is labelled with which value each column represents")
                        Text("• The columns should be represented by the values in this order:");
                        Text("• Name of the race, Name of the Democrat, Democrat vote percent, Democrat vote count, Link to a picture of the Democrat, Name of the Republican, Republican vote percent, Republican vote count, Link to a picture of the Republican, Who the winner is (D for Democrat/R for Republican/N for neither)\n");
                        Text("Press the button below to view and download a premade template file");
                        Button(action: {
                            openURL(URL(string: "https://github.com/ajin232/Election-Result-Displayer/blob/main/Release/template.csv")!);
                        }, label: {
                            Text("Open template download webpage");
                        }).buttonStyle(.borderedProminent);
                        Image("downloadlink").resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 270);
                        Text("Once you have created the template file, you can use it for either the Google Sheets input tab or the Local CSV input tab. Read the following sections for more information.\n");
                        Text("Warning about commas").font(.title3).fontWeight(.semibold);
                        Text("DO NOT TYPE COMMAS INTO YOUR SPREADSHEET!").fontWeight(.semibold);
                        Text("The app will not be able to read your data if you do. For example, avoid typing **123,456** and type **123456** instead. Avoid typing **Al Gore, Jr.** and type **Al Gore Jr.** instead.\n");
                        Text("Information about number formatting").fontWeight(.semibold);
                        Text("Sometimes, Excel or Sheets will force numbers to be formatted with commas (e.g. 123,456 instead of 123456), and this will cause problems. Here is how to fix a cell where commas are being forced into the numbers:\n");
                        Text("**In Excel:** Right click on the cell -> **Format Cells...** -> **Number** -> **Category** box -> select **General** -> **OK**\n");
                        Text("**In Google Sheets:** Click on the cell -> Go to the menu bar and click **Format** -> **Number** -> **Automatic**\n");
                        Text("Sometimes Google Sheets can be glitchy or take a few seconds to save the changes. If the method above does not work, try first deleting the contents of the cell, then changing the formatting to Number->Automatic, and then retyping the number");
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
                        Text("Background video").font(.title3).fontWeight(.semibold);
                        Text("If the background video freezes, quit the app and reopen it.\n");
                        Text("Other issues").font(.title3).fontWeight(.semibold);
                        Text("If the app is crashing without any other explanation, check to make sure your spreadsheet doesnt have any strange letters, punctuation or whitespace where there shouldn't be any, and then try quitting and restarting the app.\n");
                        Text("About").font(.title3).fontWeight(.semibold);
                        Text("This app was written by Andrew Jin in June 2025.\n");
                    }
                }.frame(maxWidth: 800, alignment: .topLeading);
            }
        }.frame(maxWidth: 800, maxHeight: 500, alignment: .topLeading).padding(12);
    }
}

struct NSVideoPlayer: NSViewRepresentable {
    // for the looping video background
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

#Preview {
    //PanelView(googleraces: ElectionData(data: [Race]())).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext);
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext).environmentObject(CurrentRace());
}
