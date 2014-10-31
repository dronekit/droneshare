describe 'header', ->

  beforeEach ->
    browser.get('index.html')

  describe 'menu', ->
    it 'should consist of 3 menu items', ->
      list = element.all findBy.css '#navigation a'
      expect(list.count()).toBe(3)
