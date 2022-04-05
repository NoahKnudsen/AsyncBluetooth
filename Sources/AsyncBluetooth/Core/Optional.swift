//
//  Created by Noah Knudsen on 04/04/2022.
//

extension Optional {
    
    func unwrapOrThrow(_ e: Error) throws -> Wrapped {
        guard let o = self else { throw e }
        return o
    }
}
