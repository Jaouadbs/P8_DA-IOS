//
//  AddExerciseViewModelTests..swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.

//  Ce qu'on teste :
//      Validation des données saisies (durée, catégorie)
//      Vérification de l'utilisateur avant l'enregistrement
//      Comportement en cas d'erreur du repository
//      Formatage statique des intensités
//


import XCTest
@testable import Arista

final class AddExerciseViewModelTests: XCTestCase {
    
    // MARK: - Helpers
    
    /// Crée un UserModel représentant Charlotte Razoul.
    /// Réutilisé dans tous les tests qui nécessitent un utilisateur valide.
    private func makeCharlotte() -> UserModel {
        UserModel(
            firstName:          "Charlotte",
            lastName:           "Razoul",
            email:              "charlotte@example.com",
            dailyStepGoal:      10_000,
            sleepHoursGoal:     480,
            hydrationMlGoal:    2_000,
            caloriesBurnedGoal: 500
        )
    }
    
    /// Fabrique un AddExerciseViewModel configuré avec des Mocks.
    /// Returns: Le ViewModel testé + le MockExerciseRepository (pour vérifier les appels).
    private func makeViewModel(
        exerciseError: Error? = nil,
        withUser:      Bool   = true,
        userError:     Error? = nil
    ) -> (AddExerciseViewModel, MockExerciseRepository) {
        let exerciseRepo = MockExerciseRepository(error: exerciseError)
        let userRepo     = MockUserRepository(
            user:  withUser ? makeCharlotte() : nil,  // nil uniquement si withUser: false
            error: userError
        )
        let vm = AddExerciseViewModel(
            exerciseRepository: exerciseRepo,
            userRepository:     userRepo
        )
        return (vm, exerciseRepo)
    }
    
    // MARK: - Tests — validation des données
    
    /// Vérifie que addExercise() retourne false si la durée vaut 0.
    /// Le repository ne doit pas être appelé — on échoue avant.
    func test_WhenDurationIsZero_AddExercise_ReturnsFalseWithErrorMessage() {
        // GIVEN — durée invalide
        let (viewModel, mockRepo) = makeViewModel()
        viewModel.duration = 0
        
        // WHEN
        let result = viewModel.addExercise()
        
        // THEN
        XCTAssertFalse(result)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(mockRepo.addExercisesCallCount, 0)
    }
    
    /// Vérifie que addExercise() retourne false si la catégorie est vide ou ne contient que des espaces.
    func test_WhenCategoryIsEmpty_AddExercise_ReturnsFalseWithErrorMessage() {
        // GIVEN — catégorie invalide (espaces uniquement)
        let (viewModel, mockRepo) = makeViewModel()
        viewModel.category = "   "
        viewModel.duration = 30
        
        // WHEN
        let result = viewModel.addExercise()
        
        // THEN
        XCTAssertFalse(result)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(mockRepo.addExercisesCallCount, 0)
    }
    
    // MARK: - Tests — vérification de l'utilisateur
    
    /// Vérifie que addExercise() retourne false si aucun utilisateur n'existe en base.
    /// Le ViewModel doit bloquer l'enregistrement AVANT d'appeler le repository d'exercice.
    func test_WhenUserIsNil_AddExercise_ReturnsFalseWithErrorMessage() {
        // GIVEN — aucun utilisateur (withUser: false → MockUserRepository retourne nil)
        let (viewModel, mockRepo) = makeViewModel(withUser: false)
        viewModel.category = "cardio"
        viewModel.duration = 30
        
        // WHEN
        let result = viewModel.addExercise()
        
        // THEN
        XCTAssertFalse(result)
        XCTAssertEqual(
            viewModel.errorMessage,
            "Aucun utilisateur trouvé. Impossible d'enregistrer l'exercice")
        // Le repository exercice ne doit jamais être appelé si l'utilisateur est absent
        XCTAssertEqual(mockRepo.addExercisesCallCount, 0)
    }
    
    /// Vérifie que addExercise() retourne false si le UserRepository lève une erreur.
    /// Et que le repository d'exercice n'est pas appelé dans ce cas.
    func test_WhenUserRepositoryThrows_AddExercise_ReturnsFalseAndDoesNotCallExerciseRepository() {
        // GIVEN — le UserRepository lève une erreur 
        let (viewModel, mockRepo) = makeViewModel(
            userError: NSError(domain: "test", code: 2)
        )
        viewModel.category = "sport"
        viewModel.duration = 20
        
        // WHEN
        let result = viewModel.addExercise()
        
        // THEN
        XCTAssertFalse(result)
        XCTAssertNotNil(viewModel.errorMessage)
        // La vérification utilisateur doit court-circuiter l'appel au repository d'exercice
        XCTAssertEqual(mockRepo.addExercisesCallCount, 0)
    }
    
    // MARK: - Tests — cas nominal
    
    /// Vérifie que addExercise() retourne true et transmet les bonnes valeurs au repository
    /// quand toutes les données sont valides et l'utilisateur existe.
    func test_WhenDataIsValid_AddExercise_ReturnsTrueAndCallsRepositoryWithCorrectValues() {
        // GIVEN — données valides + Charlotte existe
        let (viewModel, mockRepo) = makeViewModel()
        let date = Date()
        viewModel.category  = "cardio"
        viewModel.duration  = 45
        viewModel.intensity = "elevee"
        viewModel.startTime = date
        
        // WHEN
        let result = viewModel.addExercise()
        
        // THEN
        XCTAssertTrue(result)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockRepo.addExercisesCallCount, 1)
        // Vérification que le ViewModel transmet correctement les valeurs du formulaire
        XCTAssertEqual(mockRepo.lastAddedCategory,  "cardio")
        XCTAssertEqual(mockRepo.lastAddedDuration,  45)
        XCTAssertEqual(mockRepo.lastAddedIntensity, "elevee")
        XCTAssertEqual(mockRepo.lastAddedStartDate, date)
    }
    
    /// Vérifie que addExercise() retourne false si le ExerciseRepository lève une erreur
    /// (ex: CoreData inaccessible, contrainte de validation non respectée).
    func test_WhenExerciseRepositoryThrows_AddExercise_ReturnsFalseWithErrorMessage() {
        // GIVEN — le repository d'exercice est en erreur
        let (viewModel, _) = makeViewModel(
            exerciseError: NSError(
                domain: "test", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Erreur CoreData"]
            )
        )
        viewModel.category = "yoga"
        viewModel.duration = 30
        
        // WHEN
        let result = viewModel.addExercise()
        
        // THEN
        XCTAssertFalse(result)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    // MARK: - Tests — formatage statique
    
    /// Vérifie que displayIntensity() retourne le libellé lisible pour chaque valeur brute.
    /// Ces fonctions static sont testées directement sans instancier le ViewModel.
    func test_DisplayIntensity_ReturnsCorrectLabels() {
        XCTAssertEqual(AddExerciseViewModel.displayIntensity("faible"),      "Faible")
        XCTAssertEqual(AddExerciseViewModel.displayIntensity("moderee"),     "Modérée")
        XCTAssertEqual(AddExerciseViewModel.displayIntensity("elevee"),      "Elevée")
        XCTAssertEqual(AddExerciseViewModel.displayIntensity("tres_elevee"), "Très élevée")
    }
}
