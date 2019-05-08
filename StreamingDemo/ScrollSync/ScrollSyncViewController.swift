//
//  ScrollSyncViewController.swift
//  StreamingDemo
//
//  Created by kazuki.horie.ts on 2019/04/01.
//  Copyright © 2019 Kazuki Horie. All rights reserved.
//

import UIKit

class ScrollSyncViewController: UIViewController {
    @IBOutlet private weak var scrollView1: UIScrollView!
    @IBOutlet private weak var scrollView2: UIScrollView!
    @IBOutlet private weak var contentView1a: UIView!
    @IBOutlet private weak var contentView1b: UIView!
    @IBOutlet private weak var contentView2a: UIView!
    @IBOutlet private weak var contentView2b: UIView!

    @IBOutlet private weak var collectionView1: UICollectionView!
    @IBOutlet private weak var collectionView2: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView1.delegate = self
        scrollView2.delegate = self

        collectionView1.delegate = self
        collectionView2.delegate = self
        collectionView1.dataSource = self
        collectionView2.dataSource = self
        
        AppLog.debug("viewDidLoad")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setColor(to: contentView1a)
        setColor(to: contentView1b)
        setColor(to: contentView2a)
        setColor(to: contentView2b)

        scrollView1.contentOffset = contentView1b.frame.origin
        scrollView2.contentOffset = contentView2b.frame.origin

        pre1 = scrollView1.contentOffset
        pre2 = scrollView2.contentOffset
        
        AppLog.warning("viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppLog.info("viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        AppLog.error("viewDidDisappear")
    }

    private func setColor(to view: UIView) {
        let gradLayer = CAGradientLayer()
        gradLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        gradLayer.contentsGravity = .bottom
        gradLayer.colors = [
            UIColor.black.cgColor,
            UIColor.red.cgColor,
            UIColor.green.cgColor,
            UIColor.yellow.cgColor,
            UIColor.blue.cgColor
        ]
        gradLayer.locations = [
            0,
            0.25,
            0.5,
            0.75,
            1
        ]
        view.layer.addSublayer(gradLayer)
    }

    private var pre1: CGPoint = .zero
    private var pre2: CGPoint = .zero
}

extension ScrollSyncViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        infinite(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        syncScrollViews(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            syncScrollViews(scrollView)
        }
    }

    private func infinite(_ scrollView: UIScrollView) {
        if scrollView is UICollectionView { return }

        let offset = scrollView.contentOffset
        let fixedOffset: CGPoint
        if offset.y < 0 {
            // 上
            fixedOffset = CGPoint(x: offset.x, y: offset.y + contentView1a.frame.height)

        } else if offset.y > 2 * contentView1a.frame.height - scrollView.frame.height {
            // 下
            fixedOffset = CGPoint(x: offset.x, y: offset.y - contentView1a.frame.height)

        } else {
            fixedOffset = offset

        }

        scrollView.contentOffset = fixedOffset

    }

    private func syncScrollViews(_ scrollView: UIScrollView) {
        let syncView: UIScrollView
        if scrollView == scrollView1 {
            syncView = scrollView2
        } else if scrollView == scrollView2 {
            syncView = scrollView1

        } else if scrollView == collectionView1 {
            syncView = collectionView2

        } else if scrollView == collectionView2 {
            syncView = collectionView1

        } else {
            return
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
            syncView.contentOffset = scrollView.contentOffset
        }, completion: nil)

    }
}

extension ScrollSyncViewController: UICollectionViewDelegate {

}

extension ScrollSyncViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ScrollSyncCell
            else { fatalError() }
        cell.label.text = "\(indexPath.row)"
        return cell
    }
}
