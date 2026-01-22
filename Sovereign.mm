#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import "dobby.h" // يجب أن يكون الملف موجوداً

// ============================================================================
// [1] قائمة الأوفستات (الدوال التي تريد تعطيلها)
// ============================================================================
static uintptr_t offsets[] = {
    0x0002A8B68, 0x1002A8B68, 0x101C87200, 0x101C85C80, 0x101C86DF0, 
    0x101C851DC, 0x101947E04, 0x101948928, 0x100C8293C, 0x101C42B90, 
    0x101C427F0, 0x101C41C70, 0x101C3F988, 0x1015C7284, 0x1005A47DC, 
    0x101C80474, 0x101C80710, 0x10093AE94, 0x10093F9A8, 0x101938A10, 
    0x10193821C, 0x101936D54, 0x10193504C, 0x100C82804, 0x100C827B8, 
    0x100C8270C, 0x100C81304, 0x100C80DD4, 0x100C80744, 0x1000757D4, 
    0x10007559C, 0x100075378, 0x10007599C, 0x101C86920, 0x101C83A10, 
    0x101C88F30, 0x101C87B00
};

// ============================================================================
// [2] دالة التعطيل (البديلة)
// ============================================================================
// هذه الدالة لا تفعل شيئاً، سنستبدل دوال الحماية بها
void NullFunction() {
    return; 
}

// ============================================================================
// [3] المحرك الذكي (Smart Engine)
// ============================================================================
static uintptr_t GetBaseAddress(const char *target) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, target)) {
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

// ============================================================================
// [4] نقطة البداية
// ============================================================================
__attribute__((constructor))
static void InitSmartHook() {
    
    // الانتظار قليلاً حتى تتحمل المكتبات
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        uintptr_t slide = GetBaseAddress("ShadowTrackerExtra");
        
        if (slide != 0) {
            int count = sizeof(offsets) / sizeof(offsets[0]);
            
            for (int i = 0; i < count; i++) {
                uintptr_t targetAddr = slide + offsets[i];
                
                // ⚡️ السحر هنا: DobbyHook
                // بدلاً من الكتابة فوق الذاكرة (كراش)، نقوم بتحويل المسار
                // DobbyHook(العنوان، الدالة_الجديدة، الدالة_القديمة)
                
                DobbyHook((void *)targetAddr, (void *)NullFunction, NULL);
            }
            
            NSLog(@"[Sovereign] ✅ Dobby Hook Applied on %d offsets.", count);
        }
    });
}
