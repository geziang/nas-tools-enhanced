import unittest

from app.downloader.client.xunlei import _XunleiInstance


class MyTestCase(unittest.TestCase):
    def test_something(self):
        xunlei = _XunleiInstance(config={
            "host": "192.168.6.107",
            "port": "2345"
        })
        download_id = xunlei.add_torrent("magnet:?xt=urn:btih:02b67838ea6636cd1c6aac028ba12ab8d25202b6")
        self.assertIsNotNone(download_id, "id is null!")


if __name__ == '__main__':
    unittest.main()
