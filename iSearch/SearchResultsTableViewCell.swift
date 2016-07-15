//
//  SearchResultsTableViewCell.swift
//  iSearch
//
//  Created by Antonio Alves on 1/7/16.
//  Copyright © 2016 Antonio Alves. All rights reserved.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var downloadTask: URLSessionDownloadTask?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255,
            blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
        
        nameLabel.text = nil
        addressLabel.text = nil
        cellImage.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func confugureSearchResult(_ searchResult:SearchResult) {
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty {
            addressLabel.text = NSLocalizedString("Unknown", comment: "Unknown artist name")
        } else {
            addressLabel.text = String(format:
                NSLocalizedString("ARTIST_NAME_LABEL_FORMAT", comment: "Format for artist name label"),
                searchResult.artistName, searchResult.kindForDisplay())
        }
        cellImage.image = UIImage(named: "Placeholder")
        if let url = URL(string: searchResult.artworkURL60) {
            downloadTask = cellImage.loadImageWithURL(url)
        }
    }

}
