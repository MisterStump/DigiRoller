# LCD interaction libraries
from lcd_lib import LCD_1inch3
from machine import Pin,SPI,PWM
# Random (for rolls)
import random



class DigiRoller():
    # Reference for screen drawing
    LCD = LCD_1inch3()
    # Hex colors got mixxed up in this library apparently, so these are not normal
    hex = {
        "black"   : 0x0000,
        "white"   : 0xFFFF,
        "red"     : 0x00F8,
        "yellow"  : 0xE0FF,
        "green"   : 0xE007
    }
    # Which dice types are available
    diceTypes = [4,6,8,10,12,20,100]
    # Order dice attributes are in
    attributeOrder = ["count", "type", "mod"]
    # Roll results get stored here, 1 for each die (when rolled)
    rollResults = []
    # Current selection default
    selectionData = {
        "die" : 1,
        "field": "count"
    }
    # Switches (buttons)
    switches = {
        "keyA"  : Pin(15,Pin.IN,Pin.PULL_UP),
        "keyB"  : Pin(17,Pin.IN,Pin.PULL_UP),
        "keyX"  : Pin(19 ,Pin.IN,Pin.PULL_UP),
        "keyY"  : Pin(21 ,Pin.IN,Pin.PULL_UP),
        "up"    : Pin(2,Pin.IN,Pin.PULL_UP),
        "down"  : Pin(18,Pin.IN,Pin.PULL_UP),
        "left"  : Pin(16,Pin.IN,Pin.PULL_UP),
        "right" : Pin(20,Pin.IN,Pin.PULL_UP),
        "ctrl"  : Pin(3,Pin.IN,Pin.PULL_UP)
    }
    # Object that will hold keypress observers. 1 = unpressed, 0 = pressed
    toggleWatch = {}
    for k in switches.keys():
        toggleWatch[k] = 1
           
    def __init__(self):
        #Establish a blank diceData to hold die settings
        self.clearDiceData()
        #Establish blank selection data
        self.clearSelectionData()
        
        #What functions each key activates
        self.buttonFunctions = {
            "keyA"  : self.buttonPress_keyA,
            "keyB"  : self.buttonPress_keyB,
            "keyX"  : self.buttonPress_keyX,
            "keyY"  : self.buttonPress_keyY,
            "up"    : self.buttonPress_up,
            "down"  : self.buttonPress_down,
            "left"  : self.buttonPress_left,
            "right" : self.buttonPress_right,
            "ctrl"  : self.buttonPress_ctrl
        } 
        
        #Draw initial screen and start running loop to listen for buttons
        self.redrawScreen()
        self.buttonMonitoringLoop()
    
    
    # Creates the dice data object. Is reset to these values when cleared
    def clearDiceData(self):
        self.diceData = [
            {
                "count" : 1,
                "type" : 8,
                "mod" : 0
            },
            {
                "count" : 0,
                "type" : 8,
                "mod" : 0
            },
            {
                "count" : 0,
                "type" : 8,
                "mod" : 0
            },
            {
                "count" : 0,
                "type" : 8,
                "mod" : 0
            }
        ]
    # Clears the selection object
    def clearSelectionData(self):
        self.selectionData = {
            "die" : 1,
            "field": "count"
        }
    
    
    # X coord based on desired character position
    @staticmethod
    def getX(col):
        offset = 10
        charSize = 24
        i = col-1
        return offset + (charSize * i)
    # Y coord based on desired character position
    @staticmethod
    def getY(row):
        offset = 10
        charSize = 24
        i = row-1
        return offset + (charSize * i)
    # what column # is needed for getX (handles 1 to 2 dynamic digit counts)
    @staticmethod
    def getFieldCol(field, dieData):
        if (field=="count"):
            return 1
        elif (field=="d"):
            len_count = len(str(dieData["count"]))
            return len_count + 1
        elif (field=="type"):
            len_count = len(str(dieData["count"]))
            return len_count + 2
        elif (field=="+"):
            len_count = len(str(dieData["count"]))
            len_type = len(str(dieData["type"]))
            return len_count + len_type + 2
        elif (field=="mod"):
            len_count = len(str(dieData["count"]))
            len_type = len(str(dieData["type"]))
            return len_count + len_type + 3
    
    
    def redrawScreen(self):
        #Clear screen
        self.LCD.fill(self.hex['black'])
        
        #Draw roll request to screen
        for rowIndex, dieData in enumerate(self.diceData):        
            #Print roll request
            dieNumber = rowIndex+1
            self.drawRollRequest(dieNumber, dieData)
            #print roll result
            if (len(self.rollResults) > 0):
                self.drawRollResult(dieNumber, dieData)
            
        #Print result total
        if (len(self.rollResults) > 0):
            self.drawRollResultTotal()
        
        #Display redrawn image
        self.LCD.show()
        
    
    
    # Draw the given roll request on a given row (1d6+0)
    def drawRollRequest(self, dieNumber, dieData):
        #Line this roll request goes on
        rowForText = dieNumber + dieNumber - 1
        #Is this line selected
        isThisLineSelected = self.selectionData["die"] == dieNumber

        #Draw selection indicator
        if (isThisLineSelected):
            selectionCol = self.getFieldCol(self.selectionData["field"], dieData)
            selectionSize = len(str(abs(dieData[self.selectionData["field"]])))
            for i in range(0,selectionSize):
                self.LCD.fill_rect(
                    self.getX(selectionCol+i),
                    self.getY(rowForText)-2,
                    24,
                    24,
                    self.hex["yellow"])
        
        #Write text
        #Define result sections
        drawTextElements = ["count", "d", "type", "+", "mod"]
        #add in d and + into the die info. They are static/logic determined
        dieData["d"] = "d"
        dieData["+"] = "+" if dieData["mod"]>=0 else "-"
        #Write each section to its line
        for textElement in drawTextElements:
            isThisElementSelected =  self.selectionData["field"]==textElement if (isThisLineSelected) else False
            textColor = self.hex["white"] if (not isThisElementSelected) else self.hex["black"]
            self.LCD.write_text(
                dieData[textElement] if type(dieData[textElement])==str else str(abs(dieData[textElement])),
                x=self.getX(self.getFieldCol(textElement, dieData)),
                y=self.getY(rowForText),
                size=3,
                color=textColor)
            
    # Draw roll results
    def drawRollResult(self, dieNumber, dieData):
        rowForText = dieNumber + dieNumber
        result = self.rollResults[dieNumber-1]
        resultLength = len(str(result))
        
        #Write result to far right of screen
        if (dieData["count"] > 0):
            self.LCD.write_text(
                str(result),
                x=self.getX(10-resultLength),
                y=self.getY(rowForText),
                size=3,
                color=self.hex["green"])
        
    #Draw total of roll results
    def drawRollResultTotal(self):
        total = sum(self.rollResults)
        totalLength = len(str(total))
        #Write 'total'
        self.LCD.write_text(
            "Total:",
            x=self.getX(1),
            y=self.getY(9),
            size=3,
            color=self.hex["green"])
        #Write total        
        self.LCD.write_text(
            str(total),
            x=self.getX(10-totalLength),
            y=self.getY(9),
            size=3,
            color=self.hex["green"])

    def buttonMonitoringLoop(self):
        # Loop for duration of script device on state
        while(1):
            # Loop over each switch and determine if a button is pressed
            for switchName, switchRef in self.switches.items():
                previousSwitchVal = self.toggleWatch[switchName] #last loop val
                self.toggleWatch[switchName] = switchRef.value() #overwrite last with current
                newSwitchVal = self.toggleWatch[switchName] #tidy variable name new value
                
                #Trigger on switch being depressed
                #To switch so it triggers on button release instead, switch the 1 and 0
                if (newSwitchVal == 0 and previousSwitchVal == 1):
                    #print(f"You pressed '{switchName}'")
                    self.buttonFunctions[switchName]()
                    self.redrawScreen()
                
    
    #Button press functions
    def buttonPress_keyA(self):
        # Clear any previous roll results
        self.rollResults = []
        # Loop over each die
        for dieData in self.diceData:
            # Roll each die 'count' many times and record each roll
            allRollResults = []
            for _ in range(0,dieData["count"]):
                allRollResults.append(random.randint(1,dieData["type"]))
            print(allRollResults)
            # Add together results and record to rollResults                          
            resultWithMod =   sum(allRollResults) + dieData["mod"]
            self.rollResults.append(resultWithMod)                           
    
    def buttonPress_keyB(self):
        # Clear diceData
        if (len(self.rollResults)==0):
            self.clearDiceData()
            self.clearSelectionData()
        # Clear roll results
        self.rollResults = []
    
    #Increment up
    def buttonPress_keyX(self):
        curDieIndex = self.selectionData["die"]-1
        curDieField = self.selectionData["field"]
        if (curDieField=="count" or curDieField=="mod"):
            self.diceData[curDieIndex][curDieField] += 1
        elif (curDieField=="type"):
            maxDieTypes = len(self.diceTypes)
            currentDieTypeIndex = self.diceTypes.index(self.diceData[curDieIndex][curDieField])
            if (currentDieTypeIndex < maxDieTypes-1):
                self.diceData[curDieIndex][curDieField] = self.diceTypes[currentDieTypeIndex+1]
    
    #Increment down
    def buttonPress_keyY(self):
        curDieIndex = self.selectionData["die"]-1
        curDieField = self.selectionData["field"]
        if (curDieField=="count"):
            if (self.diceData[curDieIndex][curDieField] > 0):
                self.diceData[curDieIndex][curDieField] -= 1
        elif (curDieField=="mod"):
            self.diceData[curDieIndex][curDieField] -= 1
        elif (curDieField=="type"):
            currentDieTypeIndex = self.diceTypes.index(self.diceData[curDieIndex][curDieField])
            if (currentDieTypeIndex > 0):
                self.diceData[curDieIndex][curDieField] = self.diceTypes[currentDieTypeIndex-1]
    
    #Move selection up
    def buttonPress_up(self):
        curDie = self.selectionData["die"]
        if (curDie > 1):
            self.selectionData["die"] = curDie-1
    
    #Move selection down
    def buttonPress_down(self):
        curDie = self.selectionData["die"]
        maxDice = len(self.diceData)
        if (curDie < maxDice):
            self.selectionData["die"] = curDie+1
    
    #Move selection left
    def buttonPress_left(self):
        curField = self.selectionData["field"]
        curIndex = self.attributeOrder.index(curField)
        if (curIndex > 0):
            nextField = self.attributeOrder[curIndex-1]
            self.selectionData["field"] = nextField
    
    #Move selection right
    def buttonPress_right(self):
        curField = self.selectionData["field"]
        curIndex = self.attributeOrder.index(curField)
        if (curIndex < 2):
            nextField = self.attributeOrder[curIndex+1]
            self.selectionData["field"] = nextField
        
    def buttonPress_ctrl(self):
        pass
    
        """     
        # Order dice attributes are in
        attributeOrder = ["count", "type", "mod"]
        # Default dice data
        diceData = [
            {
                "count" : 2,
                "type" : 6,
                "mod" : 3
            },
            {
                "count" : 10,
                "type" : 20,
                "mod" : 10
            },
            {
                "count" : 1,
                "type" : 20,
                "mod" : -3
            },
            {
                "count" : 1,
                "type" : 8,
                "mod" : 0
            }
        ]
        # Current selection default
        selectionData = {
            "die" : 1,
            "field": "count"
        }
        """




DR = DigiRoller()




