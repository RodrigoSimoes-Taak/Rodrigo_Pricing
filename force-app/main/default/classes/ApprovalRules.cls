public interface ApprovalRules {
    void checkIfNeedsApproval(List<SObject> sObjectsToEvaluate);
    void sendToApproval(List<Approval.ProcessSubmitRequest> sObjectsNeedApproval);
}