#include <sys/mman.h>
#import <Foundation/Foundation.h>
#include <string>
#include <math.h>
#include <vector>
#include <dlfcn.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#import "2.h"
#import "ViewController.h"
static uintptr_t Mithril_GetModuleBase(const std::string& targetPath) {
    uint32_t count = _dyld_image_count();
    for (int i = 0; i < count; i++) {
        std::string path = (const char *)_dyld_get_image_name(i);
        if (path.find(targetPath) != path.npos) {
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}
static void Mithril_CleanTempFiles() {
    NSString *filepath9 = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/ano_tmp"];
    NSFileManager *fileManager9 = [NSFileManager defaultManager];
    [fileManager9 removeItemAtPath:filepath9 error:nil];

    NSString *filepath91 = [NSHomeDirectory() stringByAppendingPathComponent:@"/tmp"];
    NSFileManager *fileManager91 = [NSFileManager defaultManager];
    [fileManager91 removeItemAtPath:filepath91 error:nil];
}
template<typename T>
void Mithril_Patch(vm_address_t addr, T data, int size = 0) {
    if (size == 0) size = sizeof(T);

    vm_protect(mach_task_self(), (vm_address_t) addr, size, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    memcpy((void*)addr, &data, size);
    vm_protect(mach_task_self(), (vm_address_t)addr, size, NO, VM_PROT_READ | VM_PROT_EXECUTE);
}
__attribute__((constructor))
static void Mithril_Init() {
    Mithril_CleanTempFiles();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        uintptr_t abc1 = Mithril_GetModuleBase("ShadowTrackerExtra.app/ShadowTrackerExtra");



        if (abc1 != 0) {
Mithril_Patch<int>(abc1+std::stol(std::string("0x0002A8B68"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x1002A8B68"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C87200"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C85C80"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C86DF0"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C851DC"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101947E04"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101948928"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x100C8293C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C42B90"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C427F0"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C41C70"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C3F988"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x1015C7284"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x1005A47DC"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C80474"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C80710"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x10093AE94"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x10093F9A8"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101938A10"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x10193821C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101936D54"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x10193504C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x100C82804"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x100C827B8"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x100C8270C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x100C81304"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x100C80DD4"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x100C80744"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x1000757D4"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x10007559C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x100075378"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x10007599C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C86920"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C83A10"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C88F30"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C87B00"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C6110C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8C5EC"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8C62C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8D9F8"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8E61C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8E65C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CA3F20"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CA3EEC"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CA3F14"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CA3DF0"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8E130"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C60E4C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8E66C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8E340"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CA3DD0"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C65284"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8DC40"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C60DE4"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8C494"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8D920"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8D860"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C60B60"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101D52528"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101D369A4"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101D4136C"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101D10114"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101D7BF94"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101D25238"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101D71360"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101D668EC"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C8A0EC"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C664E8"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CAE120"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C92510"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101C9B994"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CA6AC8"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CB7A94"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CCB9C8"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CD68AC"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CE1614"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CEE480"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CBC0B8"), nullptr, 16), CFSwapInt32(0xC0035FD6));
Mithril_Patch<int>(abc1+std::stol(std::string("0x101CF9128"), nullptr, 16), CFSwapInt32(0xC0035FD6));
        }
    });
}
