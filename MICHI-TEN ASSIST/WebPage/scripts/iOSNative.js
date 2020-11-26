// iOSネイティブ(WKWebView)とJavaScriptの双方向通信するためのブリジングオブジェクト
// Android版のjsをそもまま使うため、オブジェクト名も既存の「android」とする

// let result = window.prompt(native, "IsEditMode");
window.android = {
    // ネイティブメソッドを呼び出す（戻り値なし）
    callNative: function(method, params) {
        const message = {"method":method, "params":params};
        try {
            webkit.messageHandlers.iOSNative.postMessage(message);
        } catch(err) {}
    },
    
    // ネイティブメソッドを呼び出す（戻り値あり）
    fetchFromNative: function(method, params) {
        return window.prompt("iOSNative" + "." + method, params);
    },
    
    // デバグ用
    log: function(log) {
        this.callNative("log", log);
    },

    
    
    IsEditMode: function() {
        return Boolean(Number(this.fetchFromNative("IsEditMode", "")));
    },
    
    setEditMode: function(edit) {
        this.callNative("setEditMode", edit);
    },
    
    SaveEditFacility: function() {
        this.callNative("SaveEditFacility", "");
    },
    
    changeLocationFromFacility: function() {
        this.callNative("changeLocationFromFacility", "");
    },
    
    goto_camera_mode_byFacility: function(selectedStatus) {
        this.callNative("goto_camera_mode_byFacility", selectedStatus);
    },

    showCorrection: function() {
        return this.fetchFromNative("showCorrection", "");
    },
    
    goto_camera_mode: function(mode) {
        this.callNative("goto_camera_mode", mode);
    },
    
    getDataFolder: function() {
        return this.fetchFromNative("getDataFolder", "");
    },
    
    getFacilityData: function() {
        return this.fetchFromNative("getFacilityData", "");
    },
    
    getFacilityMap: function() {
        return this.fetchFromNative("getFacilityMap", "");
    },
    
    getFacilityImages: function() {
        return this.fetchFromNative("getFacilityImages", "");
    },
    
    savetFacilityData: function(s) {
        this.callNative("savetFacilityData", s);
    },
    
    getDamageLogData: function() {
        return this.fetchFromNative("getDamageLogData", "");
    },
    
    getSpecialNote: function() {
        return this.fetchFromNative("getSpecialNote", "");
    },
    
    go_ar: function() {
        this.callNative("go_ar", "");
    },
    
    go_InspectionFromFacility: function() {
        this.callNative("go_InspectionFromFacility", "");
    },
    
    StartEditFacility: function() {
        this.callNative("StartEditFacility", "");
    },
    
    changeSelectedImgFacility: function(imageFileId, selectedStatus) {
        const params = imageFileId + "," + String(selectedStatus)
        return this.fetchFromNative("changeSelectedImgFacility", params);
    },
    
    EndEditFacility: function() {
        this.callNative("EndEditFacility", "");
    },
    
    fix_from_shogen: function() {
        this.callNative("fix_from_shogen", "");
    },
    
    appendDeviceLog: function(facilitySpecId, inspectionId, damageLogId, lineNumber, action, timeStampType) {
        const params = {"facilitySpecId":facilitySpecId, "inspectionId":inspectionId, "damageLogId":damageLogId, "lineNumber":lineNumber, "action":action, "timeStampType":timeStampType};
        this.callNative("appendDeviceLog", params);
    },
    
    getInspectionData: function() {
        return this.fetchFromNative("getInspectionData", "");
    },
    
    savetInspectionPrimaryData: function(s, save) {
        const params = {"s":s, "save":save};
        this.callNative("savetInspectionPrimaryData", params);
    },
    
    savetInspectionDetailData: function(s, save) {
        const params = {"s":s, "save":save};
        this.callNative("savetInspectionDetailData", params);
    },
    
    go_Facirity: function() {
        this.callNative("go_Facirity", "");
    },
    
    go_DamageLog: function(lineNumber) {
        this.callNative("go_DamageLog", lineNumber);
    },
    
    EndInspectionDetail: function(lineNumber) {
        this.callNative("EndInspectionDetail", lineNumber);
    },
    
    StartInspectionDetail: function(lineNumber) {
        this.callNative("StartInspectionDetail", lineNumber);
    },
    
    saveDamageLogData: function(s, save, edited) {
        const params = {"s":s, "save":save, "edited":edited};
        this.callNative("saveDamageLogData", params);
    },
    
    getDamageLogImages: function() {
        return this.fetchFromNative("getDamageLogImages", "");
    },
    
    changeSelectedImgDamageLof: function(imageFileId, selectedStatus) {
        const params = imageFileId + "," + String(selectedStatus)
        return this.fetchFromNative("changeSelectedImgDamageLof", params);
    },
}
