import SwiftUI

struct ContentView: View {
    @State private var isFormPresented = false
    @State private var studentID = ""
    @State private var selectedClass = ""
    @State private var selectedHouse = "Hullett" // Default house selection
    let houseOptions = ["Hullett", "Buckley", "Bayley", "Moor", "Morrison"]
    
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                HStack {
                    Text("Waffles")
                        .font(.largeTitle)
                        .padding()
                    Spacer()
                    Button(action: {
                        isFormPresented.toggle()
                    }) {
                        Image(systemName: "person")
                            .font(.title)
                            .padding()
                    }
                }
                
                Image("raffles logo")
                    .resizable()
                    .frame(width: 100, height: 150)
                
                Text("Welcome to Raffles Institution")
                    .font(.title)
                    .padding()
                
                NavigationLink(destination: TodoView()) {
                    Text("Reminders")
                        .font(.headline)
                        .padding()
                }
                
                NavigationLink(destination: MapView()) {
                    Text("Map")
                        .font(.headline)
                        .padding()
                }
                
                NavigationLink(destination: CheerView()) {
                    Text("Cheers")
                        .font(.headline)
                        .padding()
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $isFormPresented) {
            Form {
                TextField("Student ID", text: $studentID)
                TextField("Class", text: $selectedClass)
                Picker("House", selection: $selectedHouse) {
                    ForEach(houseOptions, id: \.self) { house in
                        Text(house)
                    }
                }
                Button("Save") {
                    // Perform saving logic here using the entered data
                    isFormPresented.toggle() // Close the form after saving
                }
            }
        }
    }
}

//Todos
import SwiftUI

struct TodoView: View {

    @State private var todos = [
        Todo(title: "Placeholder 1", isDone: true),
        Todo(title: "Placeholder 2", subtitle: "Subtitle"),
        Todo(title: "Placeholder 3"),
        Todo(title: "Placeholder 4")
    ]

    @State private var showNewTodoSheet = false

    var body: some View {
        NavigationStack {
            List($todos, editActions: .all) { $todo in
                NavigationLink {
                    TodoDetailView(todo: $todo)
                } label: {
                    HStack {
                        Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle" )
                            .onTapGesture {
                                todo.isDone.toggle()
                            }
                        VStack(alignment: .leading) {
                            Text(todo.title)
                                .strikethrough(todo.isDone)
                            if !todo.subtitle.isEmpty {
                                Text(todo.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reminders")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewTodoSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewTodoSheet) {
                NewTodoView(sourceArray: $todos)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct NewTodoView: View {

    @Binding var sourceArray: [Todo]
    @State private var todoTitle = ""
    @State private var todoSubtitle = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section("Info") {
                TextField("Title", text: $todoTitle)
                TextField("Subtitle", text: $todoSubtitle)
            }

            Section("Actions") {
                Button("Save") {
                    let newTodo = Todo(title: todoTitle, subtitle: todoSubtitle)
                    sourceArray.append(newTodo)
                    dismiss()
                }
                Button("Cancel", role: .destructive) {
                    dismiss()
                }
            }
        }
    }
}

struct NewTodoView_Previews: PreviewProvider {
    static var previews: some View {
        NewTodoView(sourceArray: .constant([]))
    }
}

struct TodoDetailView: View {

    @Binding var todo: Todo
    @State private var selectedDueDate: Date // Added state for DatePicker

    init(todo: Binding<Todo>) {
        self._todo = todo
        // Initialize selectedDueDate with the todo's existing dueDate (if any)
        _selectedDueDate = State(initialValue: todo.wrappedValue.dueDate ?? Date())
    }

    var body: some View {
        Form {
            TextField("Enter your todo name", text: $todo.title)
            TextField("Enter additional details", text: $todo.subtitle)
            Toggle("Is done?", isOn: $todo.isDone)

            Section("Due Date") {
                DatePicker("Select due date", selection: $selectedDueDate, displayedComponents: .date)
            }

            Button("Save") {
                // Update the todo's dueDate with the selected date
                todo.dueDate = selectedDueDate
            }
        }
        .navigationTitle("Todo Detail")
    }
}

struct TodoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TodoDetailView(todo:
                    .constant(Todo(title: "Do up this view", subtitle: "There's nothing here yet"))
            )
        }
    }
}

struct TodoRowView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct TodoRowView_Previews: PreviewProvider {
    static var previews: some View {
        TodoRowView()
    }
}

import Foundation

struct Todo: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String = ""
    var isDone: Bool = false
    var dueDate: Date? = nil // New property for due date
}



//Map

struct MapView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var previousScale: CGFloat = 1.0
    @State private var currentDrag: CGSize = .zero
    @State private var previousDrag: CGSize = .zero
    @State private var isPanning = false

    var body: some View {
        GeometryReader { geometry in
            Image("rimap")
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(x: offset.width + currentDrag.width, y: offset.height + currentDrag.height)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = previousScale * value
                        }
                        .onEnded { value in
                            previousScale = scale
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            currentDrag = CGSize(
                                width: previousDrag.width + value.translation.width,
                                height: previousDrag.height + value.translation.height
                            )
                            withAnimation(.easeOut(duration: 0.2)) {
                                isPanning = true
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                offset.width += value.translation.width
                                offset.height += value.translation.height
                                currentDrag = .zero
                                isPanning = false
                            }
                            previousDrag.width += value.translation.width
                            previousDrag.height += value.translation.height
                        }
                )
                .frame(
                    minWidth: geometry.size.width,
                    minHeight: geometry.size.height
                )
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

//Cheer

struct CheerView: View {
    @State private var showSheet1 = false
    @State private var showSheet2 = false
    @State private var showSheet3 = false
    @State private var showSheet4 = false
    @State private var showSheet5 = false
    @State private var showSheet6 = false
    @State private var showSheet7 = false
    @State private var showSheet8 = false
    @State private var showSheet9 = false
    @State private var showSheet10 = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Spirit") {
                showSheet1.toggle()
            }
            Button("Unite") {
                showSheet2.toggle()
            }
            Button("Thunder") {
                showSheet3.toggle()
            }
            Button("R-A-F-F-L-E-S"){
                showSheet4.toggle()
            }
            Button("Rafblood"){
                showSheet5.toggle()
            }
            Button("Raffles Raffles"){
                showSheet6.toggle()
        }
            Button("Samba"){
                showSheet7.toggle()
            }
            Button("Take Them On!"){
                showSheet8.toggle()
            }
            Button("North, South, East, West"){
                showSheet9.toggle()
            }
            Button("Green Black White"){
                showSheet10.toggle()
            }
    
    
        .sheet(isPresented: $showSheet1) {
            CheerSheet(text: "Have you got the spirit? (YEAH, YEAH) \n  Can you show the spirit? (YEAH, YEAH) \n One for all, all for one \n R-A-F-F-L-E-S, RAFFLES!")
                .multilineTextAlignment(.center)
        }
        .sheet(isPresented: $showSheet2) {
            CheerSheet(text: "5…6…7…8 \n Rafflesians unite, we’ll show our might \n We’ll show them how Rafflesians fight \n We’ll walk to the fight in green, black, white \n Cause ain’t nobody’s gonna break our stride \n Cause we’re for, we’re for, Raffles ooh Raffles ah (x2) \n We’ll fight in the sun, we’ll fight in the rain \n  We’ll fight to give our school a name \n We’ll walk to the game with pride and fame cause we feel no fear and we feel no pain \n Cause we’re for, we’re for, Raffles ooh Raffles ah \n We’re for, we’re for, Raffles YEAH!")
                .multilineTextAlignment(.center)
                       }
        .sheet(isPresented: $showSheet3) {
            CheerSheet(text: "Thunder, thunder, thunderation \n We the Raffles delegation \n When we fight with determination, we create a sensation \n Thunder, thunder, thunderation \n     We the Raffles delegation \n   When we fight with determination, we create a sensation…THUNDER!")
                .multilineTextAlignment(.center)
        }
        .sheet(isPresented: $showSheet4){
            CheerSheet(text: "R-A-F-F-L-E-S // R-A-F-F-L-E-S \n Spells the name that is the best // Spells the name that is the best \n Fight with spirit, fight with zest // Fight with spirit, fight with zest \n Mighty Raffles beats the rest // Mighty Raffles beats the rest \n Strive on // Strive on \n Raffles! // Raffles! \n R-A-F-F-L-E-S // R-A-F-F-L-E-S \n What’s that // RAFFLES \n One more time // RAFFLES \n Who’s the best? // RAFFLES")
                .multilineTextAlignment(.center)
        }
        .sheet(isPresented: $showSheet5){
            CheerSheet(text: "Raffles…RAFBLOOD \n We’ve got the Rafblood flowing from our head to our feet \n And the Promethean flame is burning can you feel the heat? \n We’re watching your every move with eagle eyes \n And Gryphon strength will lead us on to touch the skies \n Cause we got pride, yeah! \n We got passion, yeah! \n We got soul, yeah! \n We got speed, yeah! \n Pride, Passion, Soul and Speed \n R-A-F-F-L-E-S (x2)…RAFFLES!")
                .multilineTextAlignment(.center)
        }
        .sheet(isPresented: $showSheet6){
            CheerSheet(text: "Raffles, Raffles ! ** (x6)")
                .multilineTextAlignment(.center)
        }
        .sheet(isPresented: $showSheet7){
            CheerSheet(text: "5...6...7...8 \n Say Ra-Ra-Ra-Raffles! (x3) \n *** RAFFLES!")
                .multilineTextAlignment(.center)
        }
        .sheet(isPresented: $showSheet8){
            CheerSheet(text: "Go Raffles, go Raffles, go! \n Take them on, take them on! (x6)")
                .multilineTextAlignment(.center)
        }
        .sheet(isPresented: $showSheet9){
            CheerSheet(text: "North **** South **** East **** West **** \n North, South, East, West, who’s the best? \n R-A-F-F-L-E-S \n ** *** **** ** Raffles! (x3)")
                .multilineTextAlignment(.center)
        }
        .sheet(isPresented: $showSheet10){
            CheerSheet(text: "Green black white \n Green black white \n Raffles Raffles fight fight fight! \n White black green \n White black green \n Raffles Raffles win win win!")
                .multilineTextAlignment(.center)
        }
        
    }
    }
}

struct CheerSheet: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.headline)
            .padding()
    }
}

struct CheerView_Previews: PreviewProvider {
    static var previews: some View {
        CheerView()
    }
    
    @main
    struct Waffles: App {
        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
    }
}
