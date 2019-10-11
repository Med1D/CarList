//
//  CarListTableViewCell.swift
//  CarList
//
//  Created by Иван Медведев on 04/10/2019.
//  Copyright © 2019 Medvedev. All rights reserved.
//

import UIKit

class CarListTableViewCell: UITableViewCell {
    
    var index: Int?
    var id: String?
    var delegate: CarListViewController?
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var carModel: UILabel!
    @IBOutlet weak var carManufacturer: UILabel!
    @IBOutlet weak var carYear: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 10
        cellView.layer.shadowColor = UIColor.gray.cgColor
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowOffset = CGSize.zero
        cellView.layer.shadowRadius = 3
        
        carImage.contentMode = .scaleAspectFill
        carImage.layer.cornerRadius = carImage.frame.height/2
        carImage.layer.borderWidth = 1.0
        carImage.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        deleteButton.addTarget(self, action: #selector(deleteCell(_:)), for: .touchUpInside)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted == true {
            cellView.backgroundColor = UIColor(red: 26/255, green: 120/255, blue: 83/255, alpha: 1.0)
        } else {
            cellView.backgroundColor = UIColor(red: 26/255, green: 100/255, blue: 83/255, alpha: 1.0)
        }
    }
    
    
    // MARK: - Actions
    
    @objc func deleteCell(_ sender: UIButton) {
        guard let index = index else { return }
        delegate?.deleteCell(sender: sender, index: index)
    }
}

protocol deleteProtocol {
    func deleteCell(sender: UIButton, index: Int)
}
