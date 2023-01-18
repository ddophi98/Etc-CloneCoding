//
//  StructClassActor.swift
//  Concurrency
//
//  Created by 김동락 on 2023/01/17.
//


/*
 
 ----------------------------------
 
 VALUE TYPES:
 - Struct, Enum, String, Int, etc.
 - Stack에 저장됨
 - 더 빠름
 - Thread-safe
 - 값을 할당하거나 넘길 때 복사본을 넘김
 
 REFERENCE TYPES:
 - Class, Function, Actor
 - Heap에 보관됨
 - 더 느림, 하지만 동기화되어있음
 - Thread-safe X
 - 값을 할당하거나 넘길 때 참조를 넘김
 
 ----------------------------------
 
 STACK:
 - value 타입을 저장함
 - stack에 할당된 변수는 메모리에 직접적으로 저장되어있고, 따라서 접근이 매우 빠름
 - 각 쓰레드는 자신만의 stack이 있음
 
 HEAP:
 - reference 타입을 저장함
 - 쓰레드 사이에서 공유됨
 
 ----------------------------------
 
 STRUCT:
 - value 기반
 - mutate 가능 (값이 바뀐 struct를 새로 생성)
 - stack에 저장
 
 CLASS:
 - reference 기반
 - heap에 저장
 - 상속 가능
 
 ACTOR:
 - class와 비슷하지만 thread-safe
 
 ----------------------------------
 
 Structs: Data Models, Views
 Classes: ViewModels
 Actors: Manager, Data Store (공유되는 것들)
 
 ----------------------------------
 
 */

import SwiftUI

class StructClassActorViewModel: ObservableObject {
    init() {
        print("VIEWMODEL INIT")
    }
}

struct StructClassActor: View {

    @StateObject private var viewModel = StructClassActorViewModel()
    let isActive: Bool
    
    init(isActive: Bool) {
        self.isActive = isActive
        print("VIEW INIT")
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? .red : .blue)
            .onAppear {
//                runTest()
            }
    }
}

struct StructClassActorHomeView: View {
    @State private var isActive: Bool = false
    
    var body: some View {
        // 탭할때마다 StructClassActor가 새롭게 초기화됨 (VIEW INIT 여러번 찍힘)
        // StructClassActorViewModel은 한번만 초기화됨 (VIEWMODEL INIT 한번만 찍힘)
        StructClassActor(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
    }
}


struct StructClassActor_Previews: PreviewProvider {
    static var previews: some View {
        StructClassActor(isActive: true)
    }
}

extension StructClassActor {
    private func runTest() {
        print("Test started!")
        structTest1()
        printDivider()
        classTest1()
    }
    
    private func structTest1() {
        let objectA = MyStruct(title: "Starting title!")
        print("ObjectA: ", objectA.title)
        
        // Value를 전달함
        // struct 안의 값을 바꾸려면 objectB를 var로 정의해야함
        var objectB = objectA
        print("ObjectB: ", objectB.title)
        
        print("ObjectB title changed.")
        
        // objectB의 title만 변함
        objectB.title = "Second title!"
        print("ObjectA: ", objectA.title)
        print("ObjectB: ", objectB.title)
    }
    
    private func classTest1() {
        let objectA = MyClass(title: "Starting title!")
        print("ObjectA: ", objectA.title)
        
        // Reference를 전달함
        // class 안의 값을 바꾸더라도 objectB를 let으로 정의해도됨
        let objectB = objectA
        print("ObjectB: ", objectB.title)
        
        print("ObjectB title changed.")
        
        // objectA의 title도 변함
        objectB.title = "Second title!"
        print("ObjectA: ", objectA.title)
        print("ObjectB: ", objectB.title)
    }
    
    // class와 거의 같음
    // + thread-safe 특성을 가지고 있음 (await)
    actor MyActor {
        var title: String
        
        init(title: String) {
            self.title = title
        }
        
        func updateTitle(newTitle: String) {
            title = newTitle
        }
    }
    
    private func actorTest1() {
        Task {
            let objectA = MyActor(title: "Starting title!")
            // actor 프로퍼티에 접근할때마다 await 해줘야함
            await print("ObjectA: ", objectA.title)
            
            let objectB = objectA
            await print("ObjectB: ", objectB.title)
            
            print("ObjectB title changed.")

            await objectB.updateTitle(newTitle: "Second title!")
            await print("ObjectA: ", objectA.title)
            await print("ObjectB: ", objectB.title)
        }
    }
    
    private func printDivider() {
        print("""
            
        --------------------------------

        """)
    }
}


struct MyStruct {
    var title: String
}

// Immutable struct
struct CustomStruct {
    let title: String
    
    func updateTitle(newTitle: String) -> Self {
        CustomStruct(title: newTitle)
    }
}

struct MutatingStruct {
    private(set) var title: String
    
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActor {
    private func structTest2() {
        var struct1 = MyStruct(title: "Title1")
        print("Struct1: ", struct1.title)
        
        // struct 안의 변수가 var이면 이렇게 변경 가능
        struct1.title = "Title2"
        print("Struct1: ", struct1.title)
        
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2: ", struct2.title)
        
        // struct 안의 변수가 let이면 이렇게 변경 가능
        struct2 = CustomStruct(title: "Title2")
        print("Struct2: ", struct2.title)
        
        var struct3 = CustomStruct(title: "Title1")
        print("Struct3: ", struct3.title)
        
        // 매번 구조체 새로 정의하기 귀찮다면 이런걸 해주는 함수 생성하고 호출
        struct3 = struct3.updateTitle(newTitle: "Title2")
        print("Struct3: ", struct3.title)
        
        var struct4 = MutatingStruct(title: "Title1")
        print("Struct4: ", struct4.title)
        
        // mutating 함수를 통해 var 변수 변경 가능
        // var 변수 자체에는 접근하지 못하게 하면서 변경하고 싶을 때 사용 가능
        struct4.updateTitle(newTitle: "Title2")
        print("Struct4: ", struct4.title)
    }
}

class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActor {
    private func classTest2() {
        let class1 = MyClass(title: "Title1")
        print("Class1: ", class1.title)
        
        class1.title = "Title2"
        print("Class1: ", class1.title)
        
        let class2 = MyClass(title: "Title1")
        print("Class2: ", class2.title)
        
        // mutating일 필요 없음
        class2.updateTitle(newTitle: "Title2")
        print("Class2: ", class2.title)
    }
}
