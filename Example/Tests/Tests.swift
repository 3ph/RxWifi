// https://github.com/Quick/Quick

import Quick
import Nimble
import RxNimble
import RxWifi

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("Sanity") {

            // NOTE: these test work for TraviwCI
            // wifi is always disabled
            it("isEnabled") {
                expect(RxWifi.shared.isEnabled) == true
            }

            // wifi is always disconnected
            it("isConnected") {
                expect(RxWifi.shared.isEnabled) == true
            }
            
            // no ssid in simulator
            it("SSID") {
                expect(RxWifi.shared.connectedSsid).to(beNil())
            }

            /*
            it("ConnectFailure") {
                let observable = RxWifi.shared.connect(ssid: String(), password: String())
                expect(observable).first.toNot(equal(.success))
            }
 */
        }
    }
}
