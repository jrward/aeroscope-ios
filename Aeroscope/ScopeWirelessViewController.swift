//
//  ScopeWirelessViewController.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 10/1/15.
//  Copyright © 2015 Jonathan Ward. All rights reserved.
//

import UIKit
import Themeable

@IBDesignable
class ScopeWirelessViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ScanningDelegate, Themeable {

    let scope = Scope.sharedInstance
    let comms = Scope.sharedInstance.comms
    let settings = Scope.sharedInstance.settings
    
    let prefs = UserDefaults.standard
    
    var getNameModal = UIAlertController(title: "Edit Name", message: "Enter a new name (19 characters max)", preferredStyle: .alert)
    
    var textColor: UIColor = ScopeTheme.manager.activeTheme.text
    var tintColor: UIColor = ScopeTheme.manager.activeTheme.tint
    
    
    @IBOutlet weak var scanningLabel: UILabel!
    @IBOutlet weak var scanningIndicator: UIActivityIndicatorView!

    
    @IBOutlet weak var connectedLabel: UILabel!
    
    @IBOutlet weak var wirelessTable: UITableView!
    
    @IBOutlet weak var disconnectButton: UIButton!
    
    @IBOutlet weak var wirelessStatus: UILabel!
    
    @IBOutlet weak var editNameButton: UIButton!
    
    @IBAction func editNameButtonTouched(_ sender: UIButton) {
        presentGetNameModal()
    }
    
    
    @IBAction func disconnectButtonTouched(_ sender: UIButton) {
 
        //scope.settings.setRunState(.stop)
//        settings.scopeCtrl.run.value = false;
//        settings.scopeCtrl.single.value = false
        //settings.settings.update_cpu_settings()
//        settings.settings.send_cpu_setttings()
        
        //TODO: Push some of this into model
        if let peripheral = comms.peripheral {
            comms.centralManager.cancelPeripheralConnection(peripheral.bt)
        }
        comms.peripheral = nil
        prefs.removeObject(forKey: "My Aeroscope")
        scope.connection.didDisconnect()
        comms.startScanning()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
//        comms.devices = []
//        comms.startScanning()
//        
//        if (comms.connectStatus == .connected) {
//            setConnected()
//            addConnectedScope()
//            selectConnectedScope()
//        }
//        else {
//            setDisconnected()
//        }

        wirelessTable.dataSource = self
        wirelessTable.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: ScopeComms.notifications.peripheral, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectPeripheral), name: ScopeConnection.notifications.poweredOn, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectPeripheral), name: ScopeConnection.notifications.disconnect, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setConnecting), name: ScopeConnection.notifications.connect, object: nil)
        
        initGetNameModal()
        
        comms.scanningDelegate = self
        
        ScopeTheme.manager.register(themeable: self)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        comms.devices = []
        updateTable()
        comms.startScanning()
        
        if (comms.isScanning())
        {
            startScanning()
        }
        
        else {
            stopScanning()
        }
        
        if (scope.connection.status == .poweredOn) {
            setConnected()
            addConnectedScope()
            //selectConnectedScope()
        }
        
        else if (scope.connection.status == .connected) {
            setConnecting()
            addConnectedScope()
        }
            
        else {
            setDisconnected()
        }
        
        scanningIndicator.color = tintColor
        wirelessTable.tintColor = tintColor
        wirelessTable.separatorColor = tintColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (scope.connection.status.rawValue >= ConnectStatus.connected.rawValue) {
            comms.stopScanning()
            scanningIndicator.stopAnimating()

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTable() {
        DispatchQueue.main.async {
            self.wirelessTable.reloadData()
        }
    }
    
    func initGetNameModal()  {
        getNameModal.addTextField { (textField) in
            textField.text = ""
        }
        
        
        getNameModal.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            [weak getNameModal, settings] (_) in
            let textField = getNameModal!.textFields![0]
            if let newName = textField.text {
                settings.cmd.set(name: newName)
                self.comms.peripheral?.advertisedName = newName
                self.updateTable()
            }
        }))
        
        getNameModal.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in }))
    }
    
    func presentGetNameModal() {
        getNameModal.textFields![0].text = ""
        self.present(getNameModal, animated: true, completion: nil)

    }
    
    func setConnecting() {
        connectedLabel.text = "Connecting..."
        connectedLabel.textColor = UIColor.yellow
        disconnectButton.isEnabled = true
        disconnectButton.setTitleColor(tintColor, for: .normal)
//        editNameButton.isEnabled = true
//        editNameButton.setTitleColor(Scope.globalTintColor, for: .normal)
    }
    
    func setConnected() {
        connectedLabel.text = "Connected To:"
        connectedLabel.textColor = UIColor.green
        disconnectButton.isEnabled = true
        disconnectButton.setTitleColor(tintColor, for: .normal)
        editNameButton.isEnabled = true
        editNameButton.setTitleColor(tintColor, for: .normal)

    }
    
    func setDisconnected() {
        comms.startScanning()
        
        connectedLabel.text = "Not Connected"
        connectedLabel.textColor = textColor
        disconnectButton.isEnabled = false
        disconnectButton.setTitleColor(nil, for: .normal)
        editNameButton.isEnabled = false
        editNameButton.setTitleColor(nil, for: .normal)
        
//        if let rows = wirelessTable.indexPathsForVisibleRows {
//            for i in rows {
//               // wirelessTable.deselectRow(at: i, animated: false)
//                wirelessTable.cellForRow(at: i)?.accessoryType = .none
//            }
//        }
        
    }

    
    
    
    func addConnectedScope() {
        if let peripheral = comms.peripheral {
            if !comms.devices.contains(peripheral) {
                comms.devices.insert(peripheral, at: 0)
                print("scope inserted")
                updateTable()
            }
        }
        

    }
    
    func selectConnectedScope() {
        for (i, el) in (comms.devices.enumerated()) {
            if let peripheral = comms.peripheral {
                if el == peripheral {
                    //wirelessTable.moveRow(at: IndexPath(item: i, section:0), to: IndexPath(item: 0, section: 0))
                    wirelessTable.selectRow(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .none)
                    print("scope selected: \(i) \(el)")
                    //wirelessTable.selectRow(at: IndexPath(item: i, section: 0), animated: true, scrollPosition: .none)
                    //wirelessTable.sel
                    
                    
                }
            }
        }
    }
    
   
    
    func connectPeripheral() {
        setConnected()
        updateTable()
        
    }
    
    func disconnectPeripheral() {
        setDisconnected()
        updateTable()
    }
    
    func startScanning() {
        scanningIndicator.startAnimating()
        scanningLabel.isEnabled = true
        scanningLabel.textColor = tintColor
    }
    
    func stopScanning() {
        scanningIndicator.stopAnimating()
        //scanningLabel.isEnabled = false
        scanningLabel.textColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if scope.connection.status == .disconnected {
            let myPeripheral = comms.devices[indexPath.row]
            comms.peripheral = myPeripheral
            comms.centralManager.connect(myPeripheral.bt, options: nil)
            
        }
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comms.devices.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mycell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as UITableViewCell
        mycell.selectionStyle = .gray
        
        mycell.backgroundColor = UIColor.clear
        if comms.devices.count > indexPath.row {
            mycell.textLabel!.text = comms.devices[indexPath.row].advertisedName
            mycell.textLabel!.textColor = textColor
            if (comms.devices[indexPath.row] == comms.peripheral && scope.connection.status == .poweredOn) {
                mycell.accessoryType = .checkmark
            }
        
            else {
                mycell.accessoryType = .none
            }
        }
        
//        else {
//            print("*****WRONG TABLE COUNT*****")
//            print(comms.devices.count)
//        }
        
        return mycell
    }
    
    
    func apply(theme: ScopeTheme) {
        tintColor = theme.tint
        textColor = theme.text
        updateTable()
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//       // if !cell.isSelected {
//            cell.backgroundColor = UIColor.clear
//        
//        //}
//    }
//    
   
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
