# The principle of Low Memory Killer
　　Low Memory Killer Android OOM mechanism based on Linux, in Linux, the memory is in page unit distribution, when the application page allocation if the memory will through the following process bad process to kill in order to release the memory:
```
alloc_pages -> out_of_memory() -> select_bad_process() -> badness()
```
Through the oom_adj and memory process decides to kill the process at the Low Memory Killer, oom_adj smaller and not easy to be killed.

# driver impl
There is a kswapd kernel threads in Linux, when Linux recovery memory paging, kswapd thread will traverse a shrinker list, and execute the callback, defined as follows:
```
struct shrinker {
    int (*shrink)(int nr_to_scan, gfp_t gfp_mask);
    int seeks;      /* seeks to recreate an obj */

    /* These are for internal use */
    struct list_head list;
    long nr;        /* objs pending delete */
};
#define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
extern void register_shrinker(struct shrinker *);
extern void unregister_shrinker(struct shrinker *);
```
　　Add or remove a callback to the shrinker list by register_shrinker and unregister_shrinker. When the free memory after the Shrinker is registered to its own definition in the recovery of memory paging rules.

　　Android Low Memory Killer code in drivers/staging/android/lowmemorykiller.c, Shrinker registered in the module initialization by the following code:
```
static int lowmem_shrink(int nr_to_scan, gfp_t gfp_mask);
 
static struct shrinker lowmem_shrinker = {
        .shrink = lowmem_shrink,
        .seeks = DEFAULT_SEEKS * 16
};

static int __init lowmem_init(void)
{
        register_shrinker(&lowmem_shrinker);
        return 0;
}

static void __exit lowmem_exit(void)
{
        unregister_shrinker(&lowmem_shrinker);
}

module_init(lowmem_init);
module_exit(lowmem_exit);
```
# ref
[Android Low Memory Killer](https://www.programering.com/a/MjNzADMwATE.html)