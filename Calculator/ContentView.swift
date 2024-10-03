//
//  ContentView.swift
//  Calculator
//
//  Created by Tom Tim on 02.10.2024.
////
//  ContentView.swift
//  Calculator
//
//  Created by Tom Tim on 02.10.2024.
//



import SwiftUI
import CoreData

enum CalcButton: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"
    case equals = "="
    case clear = "AC"
    case decimal = "."
    case percent = "%"
    case negative = "+/-"
    
    var buttonColor: Color {
        switch self {
        case .add, .substract, .multiply, .divide, .equals:
            return .orange
        case .clear, .negative, .percent:
            return Color(.lightGray)
        default:
            return Color(UIColor(red: 55/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1))
        }
    }
    
}

enum Operation {
    case add, substract, multiply, divide, equals, none
}

struct ContentView: View {
    
    @State var  value = "0"
    @State var textSize = 100
    @State var currentOperation: Operation = .none
    @State var runningNumber = 0.0
    @State var currentNumber = 0.0
    @State var isNewNumber: Bool = true
    
    @Environment(\.managedObjectContext) private var viewContext
    let buttons: [[CalcButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .substract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equals]
    ]
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(value)
                        .font(.system(size: CGFloat(textSize)))
                        .lineLimit(1)
                        .foregroundStyle(.white)
                }
                .padding()
                
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { item in
                            Button(action: {
                                self.didTap(button: item)
                            },
                                   label: {
                                Text(item.rawValue)
                                    .font(.system(size: 40))
                                    .frame(width: self.buttonWith(item: item), height: self.buttonHeight())
                                    .background(buttonColor(item: item))
                                    .foregroundStyle(.white)
                                    .cornerRadius(self.buttonWith(item: item) / 2)
                            })
                        }
                    }
                    .padding(.bottom, 3)
                }
            }.padding(.bottom, 25)
        }
    }
    
    func didTap(button: CalcButton) {
        switch button {
        case .equals:
            action()
            if self.value != "Ошибка!" {
                self.value = isInteger(value: runningNumber) ? "\(Int(runningNumber))" : "\(runningNumber)"
            }
            isNewNumber = true
            currentOperation = .none
            break
        case .add, .substract, .multiply, .divide:
            if !isNewNumber {
                action()
            }
            if currentOperation != .none {
                self.value = isInteger(value: runningNumber) ? "\(Int(runningNumber))" : "\(runningNumber)"
            }
            if button == .add {
                currentOperation = .add
                runningNumber = Double(self.value) ?? 0
            } else if button == .substract {
                currentOperation = .substract
                runningNumber = Double(self.value) ?? 0
            } else if button == .multiply {
                currentOperation = .multiply
                runningNumber = Double(self.value) ?? 0
            } else if button == .divide {
                currentOperation = .divide
                runningNumber = Double(self.value) ?? 0
            }
            isNewNumber = true
            break
        case .clear:
            self.value = "0"
            textSize = 100
            currentOperation = .none
            runningNumber = 0
            isNewNumber = true
            break
        case .decimal, .negative, .percent:
            if button == .negative {
                if self.value == "0" {
                    return
                }
                if self.value.first == "-" {
                    let index = self.value.index(self.value.startIndex, offsetBy: 1)
                    self.value = String(self.value[index...])
                    
                } else {
                    self.value = "-\(self.value)"
                }
            }
            else if button == .decimal {
                if !value.contains(".") {
                    value.append(".")
                }
            }
        default:
            let number = button.rawValue
            if (!isNewNumber){
                if self.value.count == 6 {
                    textSize = 88
                }
                else if self.value.count == 7 {
                    textSize = 80
                }
                else if self.value.count == 8 {
                    textSize = 70
                }
                else if self.value.count == 9 {
                    return
                }
            }
            
            if self.isNewNumber {
                isNewNumber = false
                value = number
            }
            else {
                self.value = "\(self.value)\(number)"
            }
        }
    }
    
    func action() {
        let current = self.runningNumber
        switch currentOperation {
        case .add:
            self.runningNumber = (current + (Double(self.value) ?? 0))
        case .substract:
            self.runningNumber = (current - (Double(self.value) ?? 0))
        case .multiply:
            self.runningNumber = (current * (Double(self.value) ?? 0))
        case .divide:
            if self.value == "0" {
                self.value = "Ошибка!"
            }
            else {
                self.runningNumber = (current / (Double(self.value) ?? 0))
            }
        case .equals:
            break
        case .none:
            self.runningNumber = Double(self.value)!
            break
        }
        
    }
    
    func buttonWith(item: CalcButton) -> CGFloat {
        if item == .zero {
            return ((UIScreen.main.bounds.width - 4*8) / 4) * 2
        }
        return (UIScreen.main.bounds.width - 5*14) / 4
    }
    
    func buttonHeight() -> CGFloat {
        return (UIScreen.main.bounds.width - 5*14) / 4
    }
    
    func isInteger(value: Double) -> Bool {
            return value.truncatingRemainder(dividingBy: 1) == 0
    }
    
    func buttonColor(item: CalcButton) -> Color {
        switch item {
        case .add, .substract, .multiply, .divide, .equals:
            if item == .add && currentOperation == .add {
                return .green
            }
            else if item == .substract && currentOperation == .substract {
                return .green
            }
            else if item == .multiply && currentOperation == .multiply {
                return .green
            }
            else if item == .divide && currentOperation == .divide {
                return .green
            }
            return .orange
        case .clear, .negative, .percent:
            return Color(.lightGray)
        default:
            return Color(UIColor(red: 55/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1))
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
