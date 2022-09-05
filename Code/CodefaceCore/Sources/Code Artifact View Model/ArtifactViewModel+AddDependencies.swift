import SwiftyToolz

public extension ArtifactViewModel
{
    func addDependencies() -> ArtifactViewModel
    {
        // make view model hash map
        var viewModelHashMap = [CodeArtifact.ID : ArtifactViewModel]()
        
        applyRecursively
        {
            viewModelHashMap[$0.codeArtifact.id] = $0
        }
        
        // add view models for dependencies
        applyRecursively
        {
            artifactVM in
            
            // TODO: generalize this instead of repeating code for each kind
            
            switch artifactVM.kind
            {
            case .folder(let folder):
                for dependency in folder.partGraph.edges
                {
                    guard let sourceVM = viewModelHashMap[dependency.source.value.id],
                          let targetVM = viewModelHashMap[dependency.target.value.id]
                    else
                    {
                        log(error: "Could not find VMs for dependency from \(dependency.source.value.kindName) to \(dependency.target.value.kindName)")
                        continue
                    }
                    
                    artifactVM.partDependencies += .init(sourcePart: sourceVM,
                                                         targetPart: targetVM,
                                                         weight: dependency.count)
                }
                
            case .file(let file):
                for dependency in file.symbolGraph.edges
                {
                    guard let sourceVM = viewModelHashMap[dependency.source.value.id],
                          let targetVM = viewModelHashMap[dependency.target.value.id]
                    else { continue }
                    
                    artifactVM.partDependencies += .init(sourcePart: sourceVM,
                                                         targetPart: targetVM,
                                                         weight: dependency.count)
                }
                
            case .symbol(let symbol):
                for dependency in symbol.subsymbolGraph.edges
                {
                    guard let sourceVM = viewModelHashMap[dependency.source.value.id],
                          let targetVM = viewModelHashMap[dependency.target.value.id]
                    else { continue }
                    
                    artifactVM.partDependencies += .init(sourcePart: sourceVM,
                                                         targetPart: targetVM,
                                                         weight: dependency.count)
                }
            }
        }
        
        return self
    }

    func applyRecursively(action: (ArtifactViewModel) -> Void)
    {
        parts.forEach { $0.applyRecursively(action: action) }
        action(self)
    }
}
